#!/usr/bin/env python3
"""Integration regressions using sibling ARGVUS sources and isolated user state.

Run from any directory. Runtime commands are recorded, never sent to the desktop.
"""
import json
import os
from pathlib import Path
import re
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
if name == "hyprctl":
    if sys.argv[1:] == ["monitors"]: print("Monitor TEST-1 (ID 0):")
    if "dpms" in " ".join(sys.argv) and '"off"' in " ".join(sys.argv):
        sys.exit(int(os.environ.get("TEST_DPMS_FAIL", "0")))
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
                    shutil.copytree(component, self.system / component.name)
        calendar_themes = ROOT / "argvus-taskbar-calendar/resources/themes"
        shutil.copytree(
            calendar_themes,
            self.system / "argvus-taskbar-calendar/themes",
        )
        self.config = self.base / "config"
        self.user = self.config / "argvus"
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
                     "argvus-widget-telemetry-toggle"):
            script = mockbin / name
            script.write_text(MOCK)
            script.chmod(0o755)
        splash = self.base / "theme-splash"
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
            "TEST_COMMAND_LOG": str(self.log),
            "TEST_SPLASH_ARGS": str(self.splash_args),
            "ARGVUS_THEME_SPLASH_BIN": str(splash),
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
                    rofi = (self.user / "rofi/theme.rasi").read_text()
                    self.assertIn(f"/{theme}/theme.rasi", rofi)
                    for version in ("gtk-3.0", "gtk-4.0"):
                        settings = (self.user / version / "settings.ini").read_text()
                        prefer_dark = 0 if ("light-veil" in theme or "github-light" in theme or "light-solarized" in theme or "frost" in theme or "catppuccin-latte" in theme or "light-gruvbox" in theme) else 1
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

    def test_dunst_theme_follows_selected_theme(self):
        expected = {
            "argvus-dark-dracula": ("#BD93F9", "#282A36", "#6272A4"),
            "argvus-dark-aether": ("#3590bd", "#111316", "#B0BFCB"),
            "argvus-dark-silver": ("#595959", "#111316", "#B0BFCB"),
            "argvus-dark-slate": ("#7391a5", "#2F3541", "#A6B8C4"),
            # HEX colors are case-insensitive; accent-switch writes the Dunst
            # palette using its canonical uppercase representation.
            "argvus-dark-universe": ("#eeeeee", "#000000", "#AAAAAA"),
            "argvus-light-veil": ("#181818", "#f7f7f7", "#454545"),
            "argvus-github-light": ("#0969DA", "#FFFFFF", "#57606A"),
            "argvus-light-solarized": ("#268BD2", "#FDF6E3", "#839496"),
            "argvus-light-frost": ("#0969DA", "#F6F8FA", "#6E7781"),
            "argvus-light-catppuccin-latte": ("#1E66F5", "#EFF1F5", "#5C5F77"),
            "argvus-light-gruvbox": ("#458588", "#FBF1C7", "#3C3836"),
            "argvus-dark-gruvbox-high": ("#D79921", "#282828", "#A89984"),
            "argvus-dark-gruvbox": ("#D4BE98", "#282828", "#A89984"),
            "argvus-dark-rosepine": ("#C4A7E7", "#191724", "#E0DEF4"),
            "argvus-dark-tokio-night": ("#7AA2F7", "#1A1B26", "#C0CAF5"),
            "argvus-dark-solitude": ("#798186", "#101315", "#CACCCC"),
            "argvus-dark-sunset": ("#E2BE8A", "#0F0F0F", "#EADCCC"),
            "argvus-dark-hackerman": ("#82FB9C", "#0B0C16", "#DDF7FF"),
            "argvus-dark-monokai": ("#78DCE8", "#2D2A2E", "#FCFCFA"),
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

    def test_restart_does_not_depend_on_dpms(self):
        for fail in (False, True):
            with self.subTest(fail_dpms=fail):
                self.log.write_text("")
                self.apply("argvus-dark-aether", runtime=True, fail_dpms=fail)
                commands = self.commands()
                restart = ["argvus-sessionctl", "reload"]
                self.assertEqual(commands.count(restart), 1)
                self.assertFalse(any(c[0] == "hyprctl" and "dpms" in " ".join(c)
                                     for c in commands))

    def test_runtime_splash_receives_selected_theme_and_generated_colors(self):
        self.apply("argvus-dark-sunset", runtime=True)
        args = self.splash_args.read_text().splitlines()
        self.assertEqual(args[args.index("--theme") + 1], "argvus-dark-sunset")
        self.assertEqual(args[args.index("--background") + 1], "#0F0F0F")
        self.assertEqual(args[args.index("--foreground") + 1], "#EADCCC")
        self.assertEqual(args[args.index("--accent") + 1], "#E2BE8A")
        self.assertIn("--ready-file", args)

    def test_calendar_cache_materializes_selected_themes(self):
        expected = {
            "argvus-dark-gruvbox": "#282828",
            "argvus-dark-sunset": "#0F0F0F",
            "argvus-light-solarized": "#FDF6E3",
            "argvus-light-catppuccin-latte": "#EFF1F5",
            "argvus-light-frost": "#F6F8FA",
            "argvus-light-gruvbox": "#FBF1C7",
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
        self.env["TEST_RELOAD_FAIL"] = "1"
        result = self.apply("argvus-dark-aether", runtime=True, expected_status=1)
        self.assertNotIn("applied.", result.stdout)
        commands = self.commands()
        self.assertIn(["argvus-sessionctl", "reload"], commands)
        self.assertFalse(any(c[0] == "hyprctl" and "dpms" in " ".join(c)
                             for c in commands))

    def test_theme_menu_exposes_category_family_then_model_protocol(self):
        menu = self.system / "appearance/sh/theme-menu.sh"
        source = menu.read_text()
        self.assertIn("theme.category.dark", source)
        self.assertIn("theme.category.light", source)
        self.assertIn("theme.family.dark_aether", source)
        self.assertIn("theme.family.dracula", source)
        self.assertIn("theme.family.catppuccin_latte", source)
        self.assertIn("theme.family.light_gruvbox", source)
        self.assertIn("theme.family.dark_rosepine", source)
        self.assertIn('"$_dark_category >"', source)
        self.assertIn('"$_light_category >"', source)
        self.assertIn('"$_dark_gruvbox_high >"', source)
        self.assertIn('"$_catppuccin_latte >"', source)
        self.assertIn('"$_light_gruvbox >"', source)
        self.assertIn("theme.model.sticky", source)
        self.assertIn("theme.model.float", source)
        self.assertIn("-kb-accept-entry 'Return,KP_Enter,Right'", source)
        self.assertIn("-kb-cancel 'Escape,Left'", source)
        self.assertIn('theme.model.sticky)\") exec sh', source)
        self.assertIn('theme.model.float)\") exec sh', source)

    def test_theme_menu_releases_rofi_arrow_bindings(self):
        switcher = (self.system / "appearance/sh/theme-switch.sh").read_text()
        self.assertIn("theme-menu.sh", switcher)
        self.assertNotIn("-kb-custom-1 Right", switcher)

    def test_theme_switch_is_silent_on_success(self):
        result = self.apply("argvus-dark-aether")
        self.assertEqual(result.stdout, "")

    def test_theme_is_published_for_pre_authentication_greeter(self):
        self.apply("argvus-light-veil-float")
        projection = self.greeter_state / str(os.getuid())
        self.assertEqual(projection.read_text(), "argvus-light-veil-float\n")
        self.assertFalse((self.greeter_state / f"{os.getuid()}.tmp").exists())

    def test_catppuccin_latte_uses_its_packaged_wallpaper(self):
        self.apply("argvus-light-catppuccin-latte")
        self.assertEqual(
            os.path.expanduser(
                (self.user / "hypr/hyprpaper.conf").read_text().split("path =", 1)[1].splitlines()[0].strip()
            ),
            str(ROOT / "argvus-wallpapers/src/usr/share/backgrounds/argvus/argvus-catppuccin-latte.png"),
        )

    def test_solarized_light_uses_its_packaged_wallpaper(self):
        self.apply("argvus-light-solarized")
        self.assertEqual(
            os.path.expanduser(
                (self.user / "hypr/hyprpaper.conf").read_text().split("path =", 1)[1].splitlines()[0].strip()
            ),
            str(ROOT / "argvus-wallpapers/src/usr/share/backgrounds/argvus/argvus-solarized-light.png"),
        )

    def test_light_gruvbox_uses_its_packaged_wallpaper(self):
        self.apply("argvus-light-gruvbox")
        self.assertEqual(
            os.path.expanduser(
                (self.user / "hypr/hyprpaper.conf").read_text().split("path =", 1)[1].splitlines()[0].strip()
            ),
            str(ROOT / "argvus-wallpapers/src/usr/share/backgrounds/argvus/argvus-light-gruvbox.png"),
        )

    def test_official_superfile_themes_use_the_complete_schema(self):
        theme_dir = self.system / "app-profiles/config/superfile/theme"
        expected = set(tomllib.loads(
            (theme_dir / "argvus-github-light.toml").read_text()
        ))

        for theme_file in sorted(theme_dir.glob("*.toml")):
            with self.subTest(theme=theme_file.name):
                actual = set(tomllib.loads(theme_file.read_text()))
                self.assertEqual(actual, expected)

    def test_solitude_uses_its_packaged_wallpaper(self):
        self.apply("argvus-dark-solitude")
        self.assertEqual(
            os.path.expanduser(
                (self.user / "hypr/hyprpaper.conf").read_text().split("path =", 1)[1].splitlines()[0].strip()
            ),
            str(ROOT / "argvus-wallpapers/src/usr/share/backgrounds/argvus/argvus-solitude.png"),
        )

    def test_dark_sunset_uses_its_packaged_wallpaper(self):
        self.apply("argvus-dark-sunset")
        self.assertEqual(
            os.path.expanduser(
                (self.user / "hypr/hyprpaper.conf").read_text().split("path =", 1)[1].splitlines()[0].strip()
            ),
            str(ROOT / "argvus-wallpapers/src/usr/share/backgrounds/argvus/argvus-dark-sunset.png"),
        )

    def test_dark_hackerman_uses_its_packaged_wallpaper(self):
        self.apply("argvus-dark-hackerman")
        self.assertEqual(
            os.path.expanduser(
                (self.user / "hypr/hyprpaper.conf").read_text().split("path =", 1)[1].splitlines()[0].strip()
            ),
            str(ROOT / "argvus-wallpapers/src/usr/share/backgrounds/argvus/argvus-dark-hackerman.png"),
        )

    def test_dark_monokai_uses_its_packaged_wallpaper(self):
        self.apply("argvus-dark-monokai")
        self.assertEqual(
            os.path.expanduser(
                (self.user / "hypr/hyprpaper.conf").read_text().split("path =", 1)[1].splitlines()[0].strip()
            ),
            str(ROOT / "argvus-wallpapers/src/usr/share/backgrounds/argvus/argvus-dark-monokai.png"),
        )

    def test_dark_monokai_float_applies_geometry_and_telemetry_transparency(self):
        state_dir = self.base / "state/argvus"
        state_dir.mkdir(parents=True, exist_ok=True)
        (state_dir / "transparency").write_text("enabled\n")
        self.apply("argvus-dark-monokai-float")

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

        telemetry_theme = self.user / "waybar/themes/argvus-dark-monokai-float/widget-telemetry-theme.css"
        self.assertIn("@define-color th-window-bg rgba(45, 42, 46, 0.35);", telemetry_theme.read_text())

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

        self.apply("argvus-dark-aether")

        taskbar = (self.user / "waybar/argvus-taskbar.jsonc").read_text()
        self.assertIn('"custom/removable-devices"', taskbar)
        self.assertNotIn('"custom/storage"', taskbar)
        self.assertIn('//    "drawer": {', taskbar)
        self.assertIn('//      "custom/right-2-expander",', taskbar)
        self.assertIn('"on-click": "/usr/share/argvus/removable-devices/sh/removable-devices-menu.sh --root {x} {y}"', taskbar)

        mode_file.write_text("auto\n")
        self.apply("argvus-dark-aether")

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
        theme = "argvus-dark-aether"
        css = self.user / f"waybar/themes/{theme}/theme.css"
        css.parent.mkdir(parents=True)
        css.write_text("/* preserved custom palette */\n")
        self.apply(theme)
        self.assertIn("preserved custom palette", css.read_text())
        self.assertTrue((css.parent / "widget-telemetry-theme.css").is_file())

    def test_optional_gtk_theme_uses_component_path(self):
        custom = self.user / "gtk-4.0/themes/argvus-light-veil/gtk.css"
        custom.parent.mkdir(parents=True)
        custom.write_text("/* custom GTK override */\n")
        self.apply("argvus-light-veil")
        self.assertEqual((self.user / "gtk-4.0/gtk.css").read_text(), custom.read_text())

    def test_theme_switch_resets_spacing_to_mode_defaults(self):
        (self.user / ".spaces").write_text(
            "waybar_top=7\nwaybar_left=8\nwaybar_right=9\nwaybar_bottom=10\n"
            "waybar_pos=bottom\ngaps_out_top=0\ngaps_out_left=0\n"
            "gaps_out_right=0\ngaps_out_bottom=0\n"
        )
        self.apply("argvus-light-veil")
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

        self.apply("argvus-light-veil-float")
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

    def test_theme_switch_resets_borders_to_mode_defaults(self):
        (self.user / ".borders").write_text("rounded=1\nrounding=10\n")
        self.apply("argvus-dark-aether")
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

        self.apply("argvus-dark-aether-float")
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
