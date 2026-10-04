#!/usr/bin/env python3
"""Integration regressions using sibling ARGVUS sources and isolated user state.

Run from any directory. Runtime commands are recorded, never sent to the desktop.
"""
import json
import os
from pathlib import Path
import re
import shlex
import shutil
import subprocess
import tempfile
import tomllib
import unittest

ROOT = Path(__file__).resolve().parents[2]
MOCK = '''#!/usr/bin/env python3
import json, os, sys
from pathlib import Path
name = Path(sys.argv[0]).name
with open(os.environ["TEST_COMMAND_LOG"], "a") as log:
    log.write(json.dumps([name, *sys.argv[1:]]) + "\\n")
if name == "pgrep": sys.exit(1)
if name == "argvus-sessionctl" and sys.argv[1:] == ["reload"]:
    sys.exit(int(os.environ.get("TEST_RELOAD_FAIL", "0")))
if name == "systemctl" and sys.argv[1:] == ["--user", "reload", "argvus-config.service"]:
    sys.exit(int(os.environ.get("TEST_CONFIG_RELOAD_FAIL", "0")))
if name == "hyprctl":
    if sys.argv[1:] == ["monitors"]: print("Monitor TEST-1 (ID 0):")
    if "dpms" in " ".join(sys.argv) and '"off"' in " ".join(sys.argv):
        sys.exit(int(os.environ.get("TEST_DPMS_FAIL", "0")))
if name == "argvus-config" and sys.argv[1:3] == ["get", "/layout/variant"]:
    # argvus-config owns /layout/variant and apply_theme keeps it in sync with
    # data/.active-theme. TEST_VARIANT lets a test diverge the two on purpose.
    override = os.environ.get("TEST_VARIANT")
    if not override:
        marker = Path(os.environ["ARGVUS_CONFIG_HOME"]) / "argvus/data/.active-theme"
        theme = marker.read_text().strip() if marker.is_file() else "argvus-dark"
        override = "float" if theme.endswith("-float") else "sticky"
    print(override)
'''


class ThemeSwitchTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="argvus-theme-test-")
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.system = self.base / "system"
        self.system.mkdir()
        for repo in ROOT.glob("argvus*"):
            share = repo / "src/usr/share/argvus"
            if share.is_dir():
                for component in share.iterdir():
                    shutil.copytree(
                        component,
                        self.system / component.name,
                        dirs_exist_ok=True,
                    )
        calendar_themes = ROOT / "argvus-taskbar-calendar/resources/themes"
        shutil.copytree(
            calendar_themes,
            self.system / "argvus-taskbar-calendar/themes",
        )
        self.config = self.base / "config"
        # The ARGVUS configuration root holds exactly `config/` and `data/`;
        # every managed runtime tree, generated file and state marker lives
        # under `data/`.
        self.user = self.config / "argvus" / "data"
        self.user.mkdir(parents=True)
        self.greeter_state = self.base / "greeter-themes"
        self.greeter_state.mkdir()
        self.log = self.base / "commands.jsonl"
        self.log.touch()
        self.splash_args = self.base / "splash-args"
        mockbin = self.base / "bin"
        mockbin.mkdir()
        for name in ("hyprctl", "systemctl", "argvus-sessionctl", "pgrep",
                     "gsettings", "notify-send", "argvus-terminal", "argvus-system-monitor",
                     "argvus-widget-telemetry-toggle", "argvus-config"):
            script = mockbin / name
            script.write_text(MOCK)
            script.chmod(0o755)
        splash = self.base / "loading-theme"
        splash.write_text(
            "#!/usr/bin/env sh\n"
            "ready=''\n"
            "for arg in \"$@\"; do\n"
            "  if [ \"${previous:-}\" = --ready-file ]; then ready=\"$arg\"; fi\n"
            "  previous=\"$arg\"\n"
            "  printf '%s\\n' \"$arg\" >> \"$TEST_SPLASH_ARGS\"\n"
            "done\n"
            "[ -z \"$ready\" ] || printf 'READY\\n' > \"$ready\"\n"
        )
        splash.chmod(0o755)
        self.env = os.environ | {
            "ARGVUS_SYSTEM_CONFIG": str(self.system),
            "ARGVUS_BOOTSTRAP": str(self.system / "session/sh/bootstrap.sh"),
            "ARGVUS_CONFIG_HOME": str(self.config),
            "ARGVUS_GREETER_THEME_STATE_DIR": str(self.greeter_state),
            "XDG_CONFIG_HOME": str(self.base / "native"),
            "XDG_CACHE_HOME": str(self.base / "cache"),
            "ARGVUS_CACHE_HOME": str(self.base / "cache/argvus"),
            "ARGVUS_STATE_HOME": str(self.base / "state/argvus"),
            "XDG_STATE_HOME": str(self.base / "state"),
            "ARGVUS_NO_RUNTIME": "1",
            "ARGVUS_THEME_LOCKED": "0",
            "ARGVUS_I18N_DIR": str(ROOT / "argvus-i18n/locales"),
            "ARGVUS_BACKGROUNDS_DIR": str(ROOT / "argvus-wallpapers/src/usr/share/backgrounds"),
            "WALLPAPER_ROOT": str(ROOT / "argvus-wallpapers/src/usr/share/backgrounds/argvus"),
            "TEST_COMMAND_LOG": str(self.log),
            "TEST_SPLASH_ARGS": str(self.splash_args),
            "ARGVUS_LOADING_THEME_BIN": str(splash),
            "PATH": str(mockbin) + os.pathsep + os.environ["PATH"],
        }

    def apply(self, theme, runtime=False, fail_dpms=False, expected_status=0):
        result = subprocess.run(
            ["sh", str(self.system / "appearance/sh/theme-switch.sh"), theme],
            env=self.env | {"ARGVUS_NO_RUNTIME": "0" if runtime else "1",
                            "TEST_DPMS_FAIL": "1" if fail_dpms else "0"},
            capture_output=True, text=True, timeout=60)
        self.assertEqual(result.returncode, expected_status, result.stdout + result.stderr)
        self.assertNotRegex(result.stderr, r"No such file|cannot stat|can't open|not found")
        return result

    def commands(self):
        return [json.loads(line) for line in self.log.read_text().splitlines()]

    def test_all_pairs_float_to_sticky_and_imports(self):
        themes = self.system / "appearance/config/hypr/themes"
        for sticky in sorted(p.name for p in themes.iterdir() if not p.name.endswith("-float")):
            for theme in (sticky + "-float", sticky):
                with self.subTest(theme=theme):
                    self.apply(theme)
                    margin = 18 if theme.endswith("-float") else 0
                    bottom_margin = 18 if theme.endswith("-float") else 2
                    bar = (self.user / "waybar/argvus-taskbar.jsonc").read_text()
                    for edge in ("top", "left", "right"):
                        self.assertIn(f'"margin-{edge}": {margin}', bar)
                    self.assertIn(f'"margin-bottom": {bottom_margin}', bar)
                    widget = (self.user / "waybar/argvus-widget-telemetry.jsonc").read_text()
                    effective_left = 18 if theme.endswith("-float") else 0
                    effective_bottom = 18 if theme.endswith("-float") else 0
                    self.assertIn('"margin-top": 0', widget)
                    self.assertIn(f'"margin-left": {effective_left}', widget)
                    self.assertIn(f'"margin-bottom": {effective_bottom}', widget)
                    for css in (self.user / "waybar").glob("*.css"):
                        for ref in re.findall(r'@import url\("([^"]+)"\)', css.read_text()):
                            self.assertTrue((css.parent / ref).is_file(), (theme, css, ref))
                    self.assertTrue((self.user / f"waybar/themes/{theme}/widget-telemetry-theme.css").is_file())
                    if theme in ("one-dark", "one-dark-float"):
                        telemetry_theme = (self.user / f"waybar/themes/{theme}/widget-telemetry-theme.css").read_text()
                        self.assertIn(
                            "@define-color th-window-bg     rgba(44, 49, 58, 0.35);",
                            telemetry_theme,
                        )
                    rofi = (self.user / "rofi/theme.rasi").read_text()
                    self.assertIn(f"/{theme}/theme.rasi", rofi)
                    for version in ("gtk-3.0", "gtk-4.0"):
                        settings = (self.user / version / "settings.ini").read_text()
                        prefer_dark = 0 if ("argvus-light" in theme or "github-light" in theme or "solarized-light" in theme or "one-light" in theme or "everforest-light" in theme or "frost" in theme or "gruvbox-light" in theme or "catppuccin-latte" in theme) else 1
                        self.assertIn(f"gtk-application-prefer-dark-theme={prefer_dark}", settings)
                    palette = (self.base / "cache/argvus-control-center/theme.css").read_text()
                    self.assertIn("@define-color argvus_accent #", palette)
                    self.assertNotIn("argvus_bg", palette)
                    self.assertNotIn("@import", palette)
                    qt6ct = (self.base / "native/qt6ct/qt6ct.conf").read_text()
                    self.assertIn(
                        f"color_scheme_path = {self.user / 'qt6ct/colors' / (theme + '.conf')}",
                        qt6ct,
                    )
        self.assertFalse(any(c[0] == "gsettings" for c in self.commands()))

    def test_light_theme_surfaces_keep_transparency_for_sticky_and_float(self):
        light_themes = {
            "one-light": ("F0F0F1", "255, 255, 255"),
            "everforest-light": ("FDF6E3", "255, 255, 255"),
            "catppuccin-latte": ("EFF1F5", "230, 233, 239"),
            "gruvbox-light": ("F2E5BC", "242, 229, 188"),
            "argvus-light": ("F7F7F7", "235, 235, 235"),
        }
        for sticky, (panel_rgb, telemetry_rgb) in light_themes.items():
            for theme in (sticky, f"{sticky}-float"):
                with self.subTest(theme=theme):
                    self.apply(theme)

                    taskbar_theme = (self.user / f"waybar/themes/{theme}/theme.css").read_text()
                    self.assertRegex(
                        taskbar_theme,
                        r"@define-color th-background-rgba .*0\.85\);",
                    )
                    self.assertRegex(
                        taskbar_theme,
                        r"@define-color th-mpris-bg .*0\.85\);",
                    )

                    telemetry_theme = (
                        self.user / f"waybar/themes/{theme}/widget-telemetry-theme.css"
                    ).read_text()
                    expected_telemetry_rgb = telemetry_rgb
                    if theme == "catppuccin-latte-float":
                        expected_telemetry_rgb = "235, 235, 235"
                    self.assertIn(
                        f"@define-color th-window-bg     rgba({expected_telemetry_rgb}, 0.82);",
                        telemetry_theme,
                    )

                    control_panel_theme = (
                        self.system
                        / "control-panel/config/quickshell/argvus-control-panel/themes"
                        / theme
                        / "Theme.qml"
                    ).read_text()
                    self.assertIn(
                        f'readonly property color bgPanel:         "#D9{panel_rgb}"',
                        control_panel_theme,
                    )

        state_dir = self.base / "state/argvus"
        state_dir.mkdir(parents=True, exist_ok=True)
        (state_dir / "transparency").write_text("enabled\n")
        self.apply("one-light")

        effects = self.system / "session/sh/effects-toggle.sh"
        taskbar_css = self.user / "waybar/argvus-taskbar.css"
        telemetry_css = self.user / "waybar/argvus-widget-telemetry.css"
        self.assertIn(
            "@define-color th-background-effective @th-background-rgba;",
            taskbar_css.read_text(),
        )
        self.assertIn(
            "@define-color th-window-bg-effective @th-window-bg;",
            telemetry_css.read_text(),
        )

        (state_dir / "transparency").write_text("disabled\n")
        subprocess.run(
            ["sh", str(effects), "apply"],
            env=self.env,
            capture_output=True,
            text=True,
            check=True,
        )
        self.assertIn(
            "@define-color th-background-effective @th-background;",
            taskbar_css.read_text(),
        )
        self.assertIn(
            "@define-color th-window-bg-effective @th-background;",
            telemetry_css.read_text(),
        )

    def test_dunst_theme_follows_selected_theme(self):
        expected = {
            "dracula": ("#BD93F9", "#282A36", "#6272A4"),
            "argvus-dark": ("#3590bd", "#111316", "#B0BFCB"),
            "silver-dark": ("#595959", "#111316", "#B0BFCB"),
            "slate-dark": ("#7391a5", "#2F3541", "#A6B8C4"),
            # HEX colors are case-insensitive; accent-switch writes the Dunst
            # palette using its canonical uppercase representation.
            "universe": ("#eeeeee", "#000000", "#AAAAAA"),
            "argvus-light": ("#181818", "#f7f7f7", "#454545"),
            "github-light": ("#0969DA", "#FFFFFF", "#57606A"),
            "solarized-light": ("#268BD2", "#FDF6E3", "#839496"),
            "everforest-light": ("#3A94C5", "#FDF6E3", "#829181"),
            "frost": ("#0969DA", "#F6F8FA", "#6E7781"),
            "catppuccin-latte": ("#1E66F5", "#EFF1F5", "#5C5F77"),
            "gruvbox-light": ("#458588", "#FBF1C7", "#3C3836"),
            "gruvbox-high-dark": ("#D79921", "#282828", "#A89984"),
            "gruvbox-dark": ("#D4BE98", "#282828", "#A89984"),
            "rose-pine": ("#C4A7E7", "#191724", "#E0DEF4"),
            "tokyo-night": ("#7AA2F7", "#1A1B26", "#C0CAF5"),
            "solitude": ("#798186", "#101315", "#CACCCC"),
            "sunset": ("#E2BE8A", "#0F0F0F", "#EADCCC"),
            "hackerman": ("#82FB9C", "#0B0C16", "#DDF7FF"),
            "monokai-dark": ("#78DCE8", "#2D2A2E", "#FCFCFA"),
        }

        for theme, (highlight, background, foreground) in expected.items():
            with self.subTest(theme=theme):
                self.apply(theme)
                config = (self.user / "dunst/dunstrc").read_text()
                normalized_config = config.casefold()
                self.assertIn(f'highlight = "{highlight}"'.casefold(), normalized_config)
                self.assertIn(f'background = "{background}"'.casefold(), normalized_config)
                self.assertIn(f'foreground = "{foreground}"'.casefold(), normalized_config)
                self.assertIn("[discord]", config)

    def test_theme_menu_enters_dark_category(self):
        """The hierarchical Rofi menu must not abort on the Dark branch."""
        rofi_step = self.base / "rofi-step"
        selected_theme = self.base / "selected-theme"
        rofi = self.base / "bin" / "rofi"
        rofi.write_text(
            "#!/bin/sh\n"
            f"step_file={shlex.quote(str(rofi_step))}\n"
            "step=$(cat \"$step_file\" 2>/dev/null || printf '0')\n"
            "cat >/dev/null\n"
            "case \"$step\" in\n"
            "  0) printf '%s\\n' 'Dark >' ;;\n"
            "  1) printf '%s\\n' 'ARGVUS Dark' ;;\n"
            "  *) exit 1 ;;\n"
            "esac\n"
            "printf '%s\\n' $((step + 1)) >\"$step_file\"\n"
        )
        rofi.chmod(0o755)
        theme_switch = self.system / "appearance/sh/theme-switch.sh"
        theme_switch.write_text(
            "#!/bin/sh\n"
            f"printf '%s\\n' \"$1\" > {shlex.quote(str(selected_theme))}\n"
        )
        theme_switch.chmod(0o755)

        result = subprocess.run(
            ["sh", str(self.system / "appearance/sh/theme-menu.sh")],
            env=self.env | {"ARGVUS_NO_RUNTIME": "1"},
            capture_output=True,
            text=True,
            timeout=10,
        )

        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(selected_theme.read_text(), "argvus-dark\n")
        self.assertNotIn("unbound variable", result.stderr)

    def test_theme_menu_left_returns_to_parent_menu(self):
        """Cancelling a child Rofi menu with Left returns to its parent."""
        rofi_step = self.base / "rofi-step"
        selected_theme = self.base / "selected-theme"
        rofi = self.base / "bin" / "rofi"
        rofi.write_text(
            "#!/bin/sh\n"
            f"step_file={shlex.quote(str(rofi_step))}\n"
            "step=$(cat \"$step_file\" 2>/dev/null || printf '0')\n"
            "cat >/dev/null\n"
            "case \"$step\" in\n"
            "  0) printf '%s\\n' 'Dark >' ;;\n"
            "  1) printf '%s\\n' $((step + 1)) >\"$step_file\"; exit 1 ;;\n"
            "  2) printf '%s\\n' 'Light >' ;;\n"
            "  3) printf '%s\\n' 'ARGVUS Light' ;;\n"
            "  *) exit 1 ;;\n"
            "esac\n"
            "printf '%s\\n' $((step + 1)) >\"$step_file\"\n"
        )
        rofi.chmod(0o755)
        theme_switch = self.system / "appearance/sh/theme-switch.sh"
        theme_switch.write_text(
            "#!/bin/sh\n"
            f"printf '%s\\n' \"$1\" > {shlex.quote(str(selected_theme))}\n"
        )
        theme_switch.chmod(0o755)

        result = subprocess.run(
            ["sh", str(self.system / "appearance/sh/theme-menu.sh")],
            env=self.env | {"ARGVUS_NO_RUNTIME": "1"},
            capture_output=True,
            text=True,
            timeout=10,
        )

        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(selected_theme.read_text(), "argvus-light\n")

    def test_theme_menu_lists_builtin_theme_without_cli(self):
        """The built-in theme must reach Rofi even when the CLI is missing."""
        rofi_input = self.base / "rofi-input"
        rofi_step = self.base / "rofi-step"
        rofi = self.base / "bin" / "rofi"
        rofi.write_text(
            "#!/bin/sh\n"
            f"step_file={shlex.quote(str(rofi_step))}\n"
            "step=$(cat \"$step_file\" 2>/dev/null || printf '0')\n"
            "case \"$step\" in\n"
            "  0) cat >/dev/null; printf '%s\\n' 'Dark >' ;;\n"
            f"  1) cat > {shlex.quote(str(rofi_input))}; "
            "printf '%s\\n' 2 >\"$step_file\"; exit 1 ;;\n"
            "  *) cat >/dev/null; exit 1 ;;\n"
            "esac\n"
            "printf '%s\\n' $((step + 1)) >\"$step_file\"\n"
        )
        rofi.chmod(0o755)

        subprocess.run(
            ["sh", str(self.system / "appearance/sh/theme-menu.sh")],
            env=self.env | {"ARGVUS_NO_RUNTIME": "1"},
            capture_output=True,
            text=True,
            timeout=10,
        )

        items = rofi_input.read_text().splitlines()
        self.assertEqual(items[0], "ARGVUS Dark")
        # Drop-in packages are listed from their manifests, without the CLI.
        self.assertIn("One Dark", items)
        self.assertNotIn("One Light", items)
        self.assertFalse(any(item.endswith(">") for item in items))

    def test_restart_does_not_depend_on_dpms(self):
        for fail in (False, True):
            with self.subTest(fail_dpms=fail):
                self.log.write_text("")
                self.apply("argvus-dark", runtime=True, fail_dpms=fail)
                commands = self.commands()
                self.assertEqual(
                    commands.count(["systemctl", "--user", "reload", "argvus-config.service"]),
                    1,
                )
                self.assertNotIn(["argvus-sessionctl", "reload"], commands)
                self.assertFalse(any(c[0] == "hyprctl" and "dpms" in " ".join(c)
                                     for c in commands))

    def test_non_runtime_materialization_does_not_reload_session_services(self):
        self.log.write_text("")
        self.apply("argvus-dark", runtime=False)
        self.assertNotIn(
            ["systemctl", "--user", "reload", "argvus-config.service"],
            self.commands(),
        )

    def test_runtime_splash_receives_selected_theme_and_generated_colors(self):
        self.apply("sunset", runtime=True)
        args = self.splash_args.read_text().splitlines()
        self.assertEqual(args[args.index("--theme") + 1], "sunset")
        self.assertEqual(args[args.index("--background") + 1], "#0F0F0F")
        self.assertEqual(args[args.index("--foreground") + 1], "#EADCCC")
        self.assertEqual(args[args.index("--accent") + 1], "#E2BE8A")
        self.assertIn("--ready-file", args)

    def test_runtime_splash_stays_until_config_reload_finishes(self):
        events = self.base / "splash-events"
        splash = self.base / "loading-theme"
        splash.write_text(
            "#!/usr/bin/env sh\n"
            "printf 'START\\n' >> \"$TEST_SPLASH_EVENTS\"\n"
            "ready=''\n"
            "for arg in \"$@\"; do\n"
            "  if [ \"${previous:-}\" = --ready-file ]; then ready=\"$arg\"; fi\n"
            "  previous=\"$arg\"\n"
            "done\n"
            "[ -z \"$ready\" ] || printf 'READY\\n' > \"$ready\"\n"
            "trap \"printf 'STOP\\\\n' >> \\\"$TEST_SPLASH_EVENTS\\\"; exit 0\" TERM INT\n"
            "while :; do sleep 0.02; done\n"
        )
        splash.chmod(0o755)
        systemctl = self.base / "bin/systemctl"
        systemctl.write_text(
            "#!/usr/bin/env sh\n"
            "if [ \"$1\" = --user ] && [ \"$2\" = reload ]; then\n"
            "  printf 'RELOAD_START\\n' >> \"$TEST_SPLASH_EVENTS\"\n"
            "  sleep 0.2\n"
            "  printf 'RELOAD_END\\n' >> \"$TEST_SPLASH_EVENTS\"\n"
            "fi\n"
        )
        systemctl.chmod(0o755)
        result = subprocess.run(
            ["sh", str(self.system / "appearance/sh/theme-switch.sh"), "sunset"],
            env=self.env | {
                "ARGVUS_NO_RUNTIME": "0",
                "ARGVUS_LOADING_THEME_BIN": str(splash),
                "TEST_SPLASH_EVENTS": str(events),
            },
            capture_output=True,
            text=True,
            timeout=10,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertLess(
            (events.read_text().splitlines()).index("RELOAD_END"),
            (events.read_text().splitlines()).index("STOP"),
        )

    def test_runtime_splash_receives_one_light_colors(self):
        self.apply("one-light", runtime=True)
        args = self.splash_args.read_text().splitlines()
        self.assertEqual(args[args.index("--theme") + 1], "one-light")
        self.assertEqual(args[args.index("--background") + 1], "#FAFAFA")
        self.assertEqual(args[args.index("--foreground") + 1], "#383A42")
        self.assertEqual(args[args.index("--accent") + 1], "#4078F2")

    def test_calendar_cache_materializes_selected_themes(self):
        expected = {
            "gruvbox-dark": "#282828",
            "sunset": "#0F0F0F",
            "solarized-light": "#FDF6E3",
            "everforest-light": "#FDF6E3",
            "catppuccin-latte": "#EFF1F5",
            "frost": "#F6F8FA",
            "gruvbox-light": "#FBF1C7",
        }

        for theme, background in expected.items():
            for selected in (theme, f"{theme}-float"):
                with self.subTest(theme=selected):
                    self.apply(selected)
                    cache = self.base / "cache/argvus-taskbar-calendar/theme.css"
                    contents = cache.read_text()
                    self.assertTrue(contents.startswith(f"/* argvus-theme: {selected} */"))
                    self.assertNotIn("@import", contents)
                    self.assertIn("@define-color argvus_bg ", contents)
                    self.assertIn(f"@define-color argvus_bg {background};", contents)
                    if selected.endswith("-float"):
                        self.assertIn("border-radius: 4px", contents)

    def test_failed_global_reload_restores_display_and_reports_failure(self):
        self.env["TEST_CONFIG_RELOAD_FAIL"] = "1"
        result = self.apply("argvus-dark", runtime=True, expected_status=1)
        self.assertNotIn("applied.", result.stdout)
        commands = self.commands()
        self.assertIn(["systemctl", "--user", "reload", "argvus-config.service"], commands)
        self.assertNotIn(["argvus-sessionctl", "reload"], commands)
        self.assertFalse(any(c[0] == "hyprctl" and "dpms" in " ".join(c)
                             for c in commands))

    def test_theme_menu_exposes_category_family_then_model_protocol(self):
        menu = self.system / "appearance/sh/theme-menu.sh"
        source = menu.read_text()
        self.assertIn("theme.category.dark", source)
        self.assertIn("theme.category.light", source)
        self.assertIn("appearance/themes.d", source)
        self.assertNotIn("argvus-appearance themes list", source)
        self.assertIn('"ARGVUS Dark"', source)
        self.assertIn('"ARGVUS Light"', source)
        self.assertNotIn("theme.family.dracula", source)
        self.assertNotIn("theme.model.sticky", source)
        self.assertIn("-kb-accept-entry 'Return,KP_Enter,Right'", source)
        self.assertIn("-kb-cancel 'Escape,Left'", source)
        self.assertIn("exec env ARGVUS_ACCENT_OFFICIAL=1 sh", source)

    def test_theme_menu_releases_rofi_arrow_bindings(self):
        switcher = (self.system / "appearance/sh/theme-switch.sh").read_text()
        self.assertIn("theme-menu.sh", switcher)
        self.assertNotIn("-kb-custom-1 Right", switcher)

    def test_theme_switch_is_silent_on_success(self):
        result = self.apply("argvus-dark")
        self.assertEqual(result.stdout, "")

    def test_theme_is_published_for_pre_authentication_greeter(self):
        self.apply("argvus-light-float")
        projection = self.greeter_state / str(os.getuid())
        self.assertEqual(projection.read_text(), "argvus-light-float\n")
        self.assertFalse((self.greeter_state / f"{os.getuid()}.tmp").exists())

    def test_catppuccin_latte_uses_its_packaged_wallpaper(self):
        self.apply("catppuccin-latte")
        self.assertEqual(
            os.path.expanduser(
                (self.user / "hypr/hyprpaper.conf").read_text().split("path =", 1)[1].splitlines()[0].strip()
            ),
            str(ROOT / "argvus-wallpapers/src/usr/share/backgrounds/argvus/abstract/light/catppuccin-latte-abstract-light.jxl"),
        )

    def test_legacy_catppuccin_id_is_migrated(self):
        self.apply("argvus-light-catppuccin-latte")
        self.assertEqual(
            (self.user / ".active-theme").read_text(),
            "catppuccin-latte\n",
        )

    def test_solarized_light_uses_its_packaged_wallpaper(self):
        self.apply("solarized-light")
        self.assertEqual(
            os.path.expanduser(
                (self.user / "hypr/hyprpaper.conf").read_text().split("path =", 1)[1].splitlines()[0].strip()
            ),
            str(ROOT / "argvus-wallpapers/src/usr/share/backgrounds/argvus/abstract/light/solarized-abstract-light.jxl"),
        )

    def test_light_gruvbox_uses_its_packaged_wallpaper(self):
        self.apply("gruvbox-light")
        self.assertEqual(
            os.path.expanduser(
                (self.user / "hypr/hyprpaper.conf").read_text().split("path =", 1)[1].splitlines()[0].strip()
            ),
            str(ROOT / "argvus-wallpapers/src/usr/share/backgrounds/argvus/abstract/light/gruvbox-abstract-light.jxl"),
        )

    def test_one_light_uses_its_packaged_wallpaper(self):
        self.apply("one-light")
        self.assertEqual(
            os.path.expanduser(
                (self.user / "hypr/hyprpaper.conf").read_text().split("path =", 1)[1].splitlines()[0].strip()
            ),
            str(ROOT / "argvus-wallpapers/src/usr/share/backgrounds/argvus/abstract/light/one-light-abstract-light.jxl"),
        )

    def test_everforest_light_uses_its_packaged_wallpaper(self):
        self.apply("everforest-light")
        self.assertEqual(
            os.path.expanduser(
                (self.user / "hypr/hyprpaper.conf").read_text().split("path =", 1)[1].splitlines()[0].strip()
            ),
            str(ROOT / "argvus-wallpapers/src/usr/share/backgrounds/argvus/abstract/light/everforest-abstract-light.jxl"),
        )

    def test_official_superfile_themes_use_the_complete_schema(self):
        theme_dir = self.system / "app-profiles/config/superfile/theme"
        expected = set(tomllib.loads(
            (theme_dir / "github-light.toml").read_text()
        ))

        for theme_file in sorted(theme_dir.glob("*.toml")):
            with self.subTest(theme=theme_file.name):
                actual = set(tomllib.loads(theme_file.read_text()))
                self.assertEqual(actual, expected)

    def test_solitude_uses_its_packaged_wallpaper(self):
        self.apply("solitude")
        self.assertEqual(
            os.path.expanduser(
                (self.user / "hypr/hyprpaper.conf").read_text().split("path =", 1)[1].splitlines()[0].strip()
            ),
            str(ROOT / "argvus-wallpapers/src/usr/share/backgrounds/argvus/abstract/dark/solitude-abstract-dark.jxl"),
        )

    def test_dark_sunset_uses_its_packaged_wallpaper(self):
        self.apply("sunset")
        self.assertEqual(
            os.path.expanduser(
                (self.user / "hypr/hyprpaper.conf").read_text().split("path =", 1)[1].splitlines()[0].strip()
            ),
            str(ROOT / "argvus-wallpapers/src/usr/share/backgrounds/argvus/abstract/dark/sunset-abstract-dark.jxl"),
        )

    def test_dark_hackerman_uses_its_packaged_wallpaper(self):
        self.apply("hackerman")
        self.assertEqual(
            os.path.expanduser(
                (self.user / "hypr/hyprpaper.conf").read_text().split("path =", 1)[1].splitlines()[0].strip()
            ),
            str(ROOT / "argvus-wallpapers/src/usr/share/backgrounds/argvus/abstract/dark/hackerman-abstract-dark.jxl"),
        )

    def test_dark_monokai_uses_its_packaged_wallpaper(self):
        self.apply("monokai-dark")
        self.assertEqual(
            os.path.expanduser(
                (self.user / "hypr/hyprpaper.conf").read_text().split("path =", 1)[1].splitlines()[0].strip()
            ),
            str(ROOT / "argvus-wallpapers/src/usr/share/backgrounds/argvus/abstract/dark/monokai-abstract-dark.jxl"),
        )

    def test_dark_rose_pine_uses_its_packaged_wallpaper(self):
        self.apply("rose-pine")
        self.assertEqual(
            os.path.expanduser(
                (self.user / "hypr/hyprpaper.conf").read_text().split("path =", 1)[1].splitlines()[0].strip()
            ),
            str(ROOT / "argvus-wallpapers/src/usr/share/backgrounds/argvus/abstract/dark/rose-pine-abstract-dark.jxl"),
        )

    def test_dark_monokai_float_applies_geometry_and_telemetry_transparency(self):
        state_dir = self.base / "state/argvus"
        state_dir.mkdir(parents=True, exist_ok=True)
        (state_dir / "transparency").write_text("enabled\n")
        self.apply("monokai-dark-float")

        spaces = subprocess.run(
            ["sh", str(self.system / "hyprland/sh/spaces-switch.sh"), "--status"],
            env=self.env,
            capture_output=True,
            text=True,
            check=True,
        ).stdout
        self.assertIn("gaps_in=10", spaces)
        self.assertIn("gaps_out_top=18", spaces)
        self.assertIn("gaps_out_bottom=18", spaces)
        self.assertIn("waybar_top=18", spaces)
        self.assertIn("waybar_bottom=18", spaces)

        borders = subprocess.run(
            ["sh", str(self.system / "hyprland/sh/borders-switch.sh"), "--status"],
            env=self.env,
            capture_output=True,
            text=True,
            check=True,
        ).stdout
        self.assertIn("rounded=1", borders)
        self.assertIn("rounding=4", borders)

        telemetry_theme = self.user / "waybar/themes/monokai-dark-float/widget-telemetry-theme.css"
        self.assertIn("@define-color th-window-bg rgba(45, 42, 46, 0.35);", telemetry_theme.read_text())

        taskbar_theme = self.user / "waybar/themes/monokai-dark-float/theme.css"
        taskbar_contents = taskbar_theme.read_text()
        self.assertIn("@define-color th-background #2D2A2E;", taskbar_contents)
        self.assertIn("@define-color th-background-rgba rgba(34, 31, 34, 0.92);", taskbar_contents)
        self.assertNotIn("@import", taskbar_contents)

        telemetry_css = self.user / "waybar/argvus-widget-telemetry.css"
        effects = self.system / "session/sh/effects-toggle.sh"
        self.assertIn("@define-color th-window-bg-effective @th-window-bg;", telemetry_css.read_text())

        (state_dir / "transparency").write_text("disabled\n")
        subprocess.run(
            ["sh", str(effects), "apply"],
            env=self.env,
            capture_output=True,
            text=True,
            check=True,
        )
        self.assertIn(
            "@define-color th-window-bg-effective @th-background;",
            telemetry_css.read_text(),
        )

        (state_dir / "transparency").write_text("enabled\n")
        subprocess.run(
            ["sh", str(effects), "apply"],
            env=self.env,
            capture_output=True,
            text=True,
            check=True,
        )
        self.assertIn(
            "@define-color th-window-bg-effective @th-window-bg;",
            telemetry_css.read_text(),
        )

    def test_theme_switch_preserves_taskbar_utility_group_mode(self):
        mode_file = self.base / "state/argvus/taskbar-right-2-mode"
        mode_file.parent.mkdir(parents=True)
        mode_file.write_text("always-expanded\n")

        self.apply("argvus-dark")

        taskbar = (self.user / "waybar/argvus-taskbar.jsonc").read_text()
        self.assertIn('"custom/removable-devices"', taskbar)
        self.assertNotIn('"custom/storage"', taskbar)
        self.assertIn('//    "drawer": {', taskbar)
        self.assertIn('//      "custom/right-2-expander",', taskbar)
        self.assertIn('"on-click": "/usr/share/argvus/removable-devices/sh/removable-devices-menu.sh --root {x} {y}"', taskbar)

        mode_file.write_text("auto\n")
        self.apply("argvus-dark")

        taskbar = (self.user / "waybar/argvus-taskbar.jsonc").read_text()
        self.assertIn('    "drawer": {', taskbar)
        self.assertIn('      "custom/right-2-expander",', taskbar)
        self.assertIn('"on-click": "argvus-removable-devices menu"', taskbar)
        self.assertNotIn('"on-click": "/usr/share/argvus/removable-devices/sh/removable-devices-menu.sh --root {x} {y}"', taskbar)
        css = (self.user / "waybar/argvus-taskbar.css").read_text()
        self.assertIn("#custom-removable-devices", css)
        self.assertNotIn("#custom-storage", css)
        self.assertIn(["argvus-widget-telemetry-toggle", "blocks", "apply"], self.commands())

    def test_partial_theme_directory_is_repaired_without_losing_edits(self):
        theme = "argvus-dark"
        css = self.user / f"waybar/themes/{theme}/theme.css"
        css.parent.mkdir(parents=True)
        css.write_text("/* preserved custom palette */\n")
        self.apply(theme)
        self.assertIn("preserved custom palette", css.read_text())
        self.assertTrue((css.parent / "widget-telemetry-theme.css").is_file())

    def test_optional_gtk_theme_uses_component_path(self):
        custom = self.user / "gtk-4.0/themes/argvus-light/gtk.css"
        custom.parent.mkdir(parents=True)
        custom.write_text("/* custom GTK override */\n")
        self.apply("argvus-light")
        self.assertEqual((self.user / "gtk-4.0/gtk.css").read_text(), custom.read_text())

    def test_theme_switch_resets_spacing_to_mode_defaults(self):
        (self.user / ".spaces").write_text(
            "waybar_top=7\nwaybar_left=8\nwaybar_right=9\nwaybar_bottom=10\n"
            "waybar_pos=bottom\ngaps_out_top=0\ngaps_out_left=0\n"
            "gaps_out_right=0\ngaps_out_bottom=0\n"
        )
        self.apply("argvus-light")
        bar = (self.user / "waybar/argvus-taskbar.jsonc").read_text()
        self.assertIn('"position": "top"', bar)
        for edge in ("top", "left", "right"):
            self.assertIn(f'"margin-{edge}": 0', bar)
        self.assertIn('"margin-bottom": 2', bar)
        spaces_status = subprocess.run(
            ["sh", str(self.system / "hyprland/sh/spaces-switch.sh"), "--status"],
            env=self.env, capture_output=True, text=True, check=True,
        ).stdout
        self.assertIn("gaps_in=2", spaces_status)
        for edge in ("top", "left", "right", "bottom"):
            self.assertIn(f"gaps_out_{edge}=0", spaces_status)

        self.apply("argvus-light-float")
        bar = (self.user / "waybar/argvus-taskbar.jsonc").read_text()
        for edge in ("top", "left", "right", "bottom"):
            self.assertIn(f'"margin-{edge}": 18', bar)
        float_spaces_status = subprocess.run(
            ["sh", str(self.system / "hyprland/sh/spaces-switch.sh"), "--status"],
            env=self.env, capture_output=True, text=True, check=True,
        ).stdout
        self.assertIn("gaps_in=10", float_spaces_status)
        for edge in ("top", "left", "right", "bottom"):
            self.assertIn(f"gaps_out_{edge}=18", float_spaces_status)

        (self.user / ".spaces").write_text(
            "waybar_top=2\nwaybar_left=4\nwaybar_right=5\nwaybar_bottom=7\n"
            "waybar_pos=top\ngaps_out_top=2\ngaps_out_left=4\n"
            "gaps_out_right=5\ngaps_out_bottom=7\n"
        )
        subprocess.run(
            ["sh", str(self.system / "hyprland/sh/spaces-switch.sh"), "--apply"],
            env=self.env | {"ARGVUS_NO_RUNTIME": "0"},
            capture_output=True, text=True, check=True,
        )
        bar = (self.user / "waybar/argvus-taskbar.jsonc").read_text()
        self.assertIn('"margin-bottom": 7', bar)
        # The generated effective geometry complements the taskbar reservation
        # instead of adding the requested gaps_out value a second time.
        self.assertIn(["hyprctl", "keyword", "general:gaps_out", "0 5 7 4"], self.commands())
        effective = (self.user / "generated/spaces-effective.conf").read_text()
        self.assertIn("effective_top=0", effective)
        self.assertIn("effective_left=4", effective)
        self.assertIn("effective_right=5", effective)
        self.assertIn("effective_bottom=7", effective)
        telemetry = (self.user / "waybar/argvus-widget-telemetry.jsonc").read_text()
        self.assertIn('"margin-top": 0', telemetry)
        self.assertIn('"margin-left": 4', telemetry)
        self.assertIn('"margin-bottom": 7', telemetry)

        (self.user / ".spaces").write_text(
            "waybar_top=6\nwaybar_left=4\nwaybar_right=5\nwaybar_bottom=7\n"
            "waybar_pos=bottom\ngaps_out_top=2\ngaps_out_left=4\n"
            "gaps_out_right=5\ngaps_out_bottom=3\n"
        )
        subprocess.run(
            ["sh", str(self.system / "hyprland/sh/spaces-switch.sh"), "--apply"],
            env=self.env | {"ARGVUS_NO_RUNTIME": "0"},
            capture_output=True, text=True, check=True,
        )
        self.assertIn(["hyprctl", "keyword", "general:gaps_out", "2 5 0 4"], self.commands())

    def test_effective_geometry_constraints_preserve_requested_state(self):
        script = self.system / "hyprland/sh/spaces-switch.sh"
        lua = (self.system / "hyprland/config/hyprland.lua").read_text()
        self.assertIn("generated/spaces-effective.conf", lua)
        self.assertIn("math.max(0, _spaces_gaps_out_top - _spaces_waybar_bottom)", lua)
        self.assertIn("math.max(0, _spaces_gaps_out_bottom - _spaces_waybar_top)", lua)
        cases = (
            ("top", "15", "15", "0", "15"),
            ("top", "5", "15", "10", "15"),
            ("top", "20", "15", "0", "15"),
            ("top", "0", "15", "15", "15"),
            ("bottom", "15", "15", "0", "15"),
            ("bottom", "5", "15", "10", "15"),
            ("bottom", "20", "15", "0", "15"),
            ("bottom", "0", "15", "15", "15"),
        )
        for position, facing, requested, expected, other in cases:
            with self.subTest(position=position, facing=facing):
                top_margin = facing if position == "bottom" else 0
                bottom_margin = facing if position == "top" else 0
                (self.user / ".spaces").write_text(
                    f"waybar_top={top_margin}\nwaybar_left=3\nwaybar_right=4\n"
                    f"waybar_bottom={bottom_margin}\nwaybar_pos={position}\n"
                    f"gaps_in=2\ngaps_out_top=15\ngaps_out_left=6\n"
                    f"gaps_out_right=7\ngaps_out_bottom=15\n"
                )
                subprocess.run(
                    ["sh", str(script), "--apply"],
                    env=self.env | {"ARGVUS_NO_RUNTIME": "0"},
                    capture_output=True, text=True, check=True,
                )
                state = (self.user / ".spaces").read_text()
                self.assertIn(f"waybar_pos={position}", state)
                self.assertIn(f"gaps_out_top={requested}", state)
                self.assertIn("gaps_out_bottom=15", state)
                status = subprocess.run(
                    ["sh", str(script), "--status"],
                    env=self.env, capture_output=True, text=True, check=True,
                ).stdout
                self.assertIn("gaps_out_top=15", status)
                self.assertIn("gaps_out_bottom=15", status)
                self.assertEqual(
                    subprocess.run(
                        ["sh", str(script), "--get", "gaps_out_top"],
                        env=self.env, capture_output=True, text=True, check=True,
                    ).stdout.strip(),
                    "15",
                )
                effective = (self.user / "generated/spaces-effective.conf").read_text()
                expected_top = expected if position == "top" else requested
                expected_bottom = expected if position == "bottom" else other
                self.assertIn(f"effective_top={expected_top}", effective)
                self.assertIn(f"effective_bottom={expected_bottom}", effective)
                self.assertIn("effective_left=6", effective)
                self.assertIn("effective_right=7", effective)

    def test_sticky_float_geometry_resolves_from_data_markers(self):
        # Guards the Sticky/Float contract end to end: the mode owns rounding,
        # the geometry from data/, while borders-switch.sh derives its defaults
        # from the canonical /layout/variant. If either reader falls back to the
        # legacy root or the .active-theme suffix, a mode change silently
        # applies spacing and borders inconsistently.
        lua = (self.system / "hyprland/config/hyprland.lua").read_text()
        for marker in (
            '.active-theme",\n  _state_home .. "/.active-theme',
            '.spaces",\n  _state_home .. "/.spaces',
            '.borders",\n  _state_home .. "/.borders',
        ):
            self.assertIn(f'_data_home .. "/{marker}', lua)
        self.assertIn(
            'theme.gaps_in = _theme_name:match("%-float$") and 4 or 2',
            lua,
        )

        for theme, expected in (
            ("argvus-dark", ("rounded=0", "rounding=0", "thickness=1")),
            ("argvus-dark-float", ("rounded=1", "rounding=4", "thickness=1")),
        ):
            with self.subTest(theme=theme):
                self.apply(theme)
                status = subprocess.run(
                    ["sh", str(self.system / "hyprland/sh/borders-switch.sh"), "--status"],
                    env=self.env, capture_output=True, text=True, check=True,
                ).stdout
                for pair in expected:
                    self.assertIn(pair, status)
                # The compositor must resolve the same mode from data/.
                active = (self.user / ".active-theme").read_text().strip()
                self.assertEqual(active, theme)
                self.assertEqual(active.endswith("-float"),
                                 "rounded=1" in status)

    def test_borders_defaults_follow_canonical_variant_not_active_theme(self):
        # A manual layout.json edit changes /layout/variant without touching the
        # .active-theme marker. borders-switch.sh must follow the canonical
        # value so borders no longer stay Sticky while spacing went Float.
        borders = self.system / "hyprland/sh/borders-switch.sh"
        self.apply("argvus-dark")
        (self.user / ".active-theme").write_text("argvus-dark")
        (self.user / ".borders").unlink(missing_ok=True)
        status = subprocess.run(
            ["sh", str(borders), "--status"],
            env=self.env, capture_output=True, text=True, check=True,
        ).stdout
        self.assertIn("rounded=0", status)

        # Simulate the canonical variant being Float while the marker still
        # reads Sticky: the canonical source must win.
        variant = self.env | {"TEST_VARIANT": "float"}
        status = subprocess.run(
            ["sh", str(borders), "--defaults"],
            env=variant, capture_output=True, text=True, check=True,
        ).stdout
        self.assertIn("rounded=1", status)
        self.assertIn("rounding=4", status)

    def test_wallpaper_custom_selection_is_cleared_on_theme_switch(self):
        # theme-switch must clear the canonical data/ marker. Clearing only the
        # legacy root copy left a stale selection that persisted_wallpaper()
        # re-applied on the next session reload.
        custom = self.user / ".wallpaper-custom"
        legacy = self.config / "argvus/.wallpaper-custom"
        custom.parent.mkdir(parents=True, exist_ok=True)
        custom.write_text("/tmp/argvus-custom-pick.jpg\n")
        legacy.write_text("/tmp/argvus-legacy-pick.jpg\n")
        self.apply("monokai-dark-float")
        self.assertFalse(custom.exists(), "canonical custom wallpaper survived")
        self.assertFalse(legacy.exists(), "legacy custom wallpaper survived")
        hyprpaper = (self.user / "hypr/hyprpaper.conf").read_text()
        self.assertNotIn("argvus-custom-pick", hyprpaper)
        self.assertNotIn("argvus-legacy-pick", hyprpaper)
        self.assertIn("monokai-abstract-dark", hyprpaper)

    def test_hypr_helper_persists_custom_wallpaper_under_data(self):
        # persist_custom_wallpaper must write data/; read_custom_wallpaper
        # prefers it and still honours a pre-migration root marker.
        helper = self.system / "appearance/sh/hypr.sh"
        self.assertIn('CUSTOM_WALLPAPER_STATE="${CUSTOM_WALLPAPER_DIR}/.wallpaper-custom"',
                      helper.read_text())
        self.assertIn('CUSTOM_WALLPAPER_DIR="${ARGVUS_CONFIG_HOME}/argvus/data"',
                      helper.read_text())
        self.assertIn('CUSTOM_WALLPAPER_LEGACY="${ARGVUS_CONFIG_HOME}/argvus/.wallpaper-custom"',
                      helper.read_text())

    def test_session_loading_prefers_data_markers(self):
        loading = (ROOT / "argvus-session/src/usr/bin/argvus-session-loading").read_text()
        self.assertIn('_theme_file="$_argvus_home/data/.active-theme"', loading)
        self.assertIn('_accent_file="$_argvus_home/data/.accent-color"', loading)
        self.assertIn('[ -s "$_theme_file" ] || _theme_file="$_argvus_home/.active-theme"',
                      loading)

    def test_toggle_mode_reads_and_writes_data_markers(self):
        toggle = (self.system / "appearance/sh/toggle-mode.sh").read_text()
        self.assertIn('GTK_MODE_FILE="$ARGVUS_CONFIG_HOME/argvus/data/.gtk-mode"', toggle)
        self.assertIn('"$ARGVUS_CONFIG_HOME/argvus/data/.active-theme"', toggle)

    def test_theme_switch_resets_borders_to_mode_defaults(self):
        (self.user / ".borders").write_text("rounded=1\nrounding=10\n")
        self.apply("argvus-dark")
        css = (self.user / "waybar/argvus-taskbar.css").read_text()
        telemetry_css = (self.user / "waybar/argvus-widget-telemetry.css").read_text()
        rofi = (self.user / "rofi/theme.rasi").read_text()
        self.assertIn("border-radius: 0px;", css)
        self.assertNotIn("border-radius: 10px;", css)
        self.assertIn("border-radius: 0px;", telemetry_css)
        self.assertIn("border-radius: 0px;", rofi)
        borders_status = subprocess.run(
            ["sh", str(self.system / "hyprland/sh/borders-switch.sh"), "--status"],
            env=self.env, capture_output=True, text=True, check=True,
        ).stdout
        self.assertIn("rounded=0", borders_status)
        self.assertIn("rounding=0", borders_status)
        self.assertIn("thickness=1", borders_status)

        self.apply("argvus-dark-float")
        css = (self.user / "waybar/argvus-taskbar.css").read_text()
        telemetry_css = (self.user / "waybar/argvus-widget-telemetry.css").read_text()
        rofi = (self.user / "rofi/theme.rasi").read_text()
        self.assertIn("border-radius: 4px;", css)
        self.assertNotIn("border-radius: 0px;", css)
        self.assertIn("border-radius: 4px;", telemetry_css)
        self.assertIn("border-radius: 4px;", rofi)
        borders_status = subprocess.run(
            ["sh", str(self.system / "hyprland/sh/borders-switch.sh"), "--status"],
            env=self.env, capture_output=True, text=True, check=True,
        ).stdout
        self.assertIn("rounded=1", borders_status)
        self.assertIn("rounding=4", borders_status)
        self.assertIn("thickness=1", borders_status)

        borders_script = self.system / "hyprland/sh/borders-switch.sh"
        subprocess.run(
            ["sh", str(borders_script), "--set-persist", "thickness", "7"],
            env=self.env, capture_output=True, text=True, check=True,
        )
        before = (self.user / "waybar/argvus-taskbar.css").read_text()
        telemetry_before = (self.user / "waybar/argvus-widget-telemetry.css").read_text()
        subprocess.run(
            ["sh", str(borders_script), "--apply"],
            env=self.env | {"ARGVUS_NO_RUNTIME": "0"},
            capture_output=True, text=True, check=True,
        )
        self.assertIn(["hyprctl", "keyword", "general:border_size", "7"], self.commands())
        self.assertEqual(before, (self.user / "waybar/argvus-taskbar.css").read_text())
        self.assertEqual(telemetry_before, (self.user / "waybar/argvus-widget-telemetry.css").read_text())


if __name__ == "__main__":
    unittest.main()
