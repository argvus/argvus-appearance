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
        self.config = self.base / "config"
        self.user = self.config / "argvus"
        self.user.mkdir(parents=True)
        self.log = self.base / "commands.jsonl"
        self.log.touch()
        mockbin = self.base / "bin"
        mockbin.mkdir()
        for name in ("hyprctl", "systemctl", "argvus-sessionctl", "pgrep",
                     "gsettings", "notify-send", "argvus-terminal", "argvus-system-monitor"):
            script = mockbin / name
            script.write_text(MOCK)
            script.chmod(0o755)
        self.env = os.environ | {
            "ARGVUS_SYSTEM_CONFIG": str(self.system),
            "ARGVUS_BOOTSTRAP": str(self.system / "session/sh/bootstrap.sh"),
            "ARGVUS_CONFIG_HOME": str(self.config),
            "XDG_CONFIG_HOME": str(self.base / "native"),
            "XDG_CACHE_HOME": str(self.base / "cache"),
            "ARGVUS_CACHE_HOME": str(self.base / "cache/argvus"),
            "ARGVUS_STATE_HOME": str(self.base / "state/argvus"),
            "XDG_STATE_HOME": str(self.base / "state"),
            "ARGVUS_NO_RUNTIME": "1",
            "ARGVUS_THEME_LOCKED": "0",
            "ARGVUS_I18N_DIR": str(ROOT / "argvus-i18n/locales"),
            "TEST_COMMAND_LOG": str(self.log),
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

    def test_all_pairs_float_to_normal_and_imports(self):
        themes = self.system / "appearance/config/hypr/themes"
        for normal in sorted(p.name for p in themes.iterdir() if not p.name.endswith("-float")):
            for theme in (normal + "-float", normal):
                with self.subTest(theme=theme):
                    self.apply(theme)
                    margin = 16 if theme.endswith("-float") else 0
                    bottom_margin = 0
                    bar = (self.user / "waybar/argvus-taskbar.jsonc").read_text()
                    for edge in ("top", "left", "right"):
                        self.assertIn(f'"margin-{edge}": {margin}', bar)
                    self.assertIn(f'"margin-bottom": {bottom_margin}', bar)
                    widget = (self.user / "waybar/argvus-widget-telemetry.jsonc").read_text()
                    self.assertIn(f'"margin-top": {margin}', widget)
                    for css in (self.user / "waybar").glob("*.css"):
                        for ref in re.findall(r'@import url\("([^"]+)"\)', css.read_text()):
                            self.assertTrue((css.parent / ref).is_file(), (theme, css, ref))
                    self.assertTrue((self.user / f"waybar/themes/{theme}/widget-telemetry-theme.css").is_file())
                    rofi = (self.user / "rofi/theme.rasi").read_text()
                    self.assertIn(f"/{theme}/theme.rasi", rofi)
                    for version in ("gtk-3.0", "gtk-4.0"):
                        settings = (self.user / version / "settings.ini").read_text()
                        prefer_dark = 0 if "light-veil" in theme else 1
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

    def test_failed_global_reload_restores_display_and_reports_failure(self):
        self.env["TEST_RELOAD_FAIL"] = "1"
        result = self.apply("argvus-dark-aether", runtime=True, expected_status=1)
        self.assertNotIn("applied.", result.stdout)
        commands = self.commands()
        self.assertIn(["argvus-sessionctl", "reload"], commands)
        self.assertFalse(any(c[0] == "hyprctl" and "dpms" in " ".join(c)
                             for c in commands))

    def test_theme_menu_exposes_family_then_model_protocol(self):
        menu = self.system / "appearance/sh/theme-menu.sh"
        source = menu.read_text()
        self.assertIn("theme.family.dark_aether", source)
        self.assertIn("theme.model.normal", source)
        self.assertIn("theme.model.float", source)
        self.assertIn("-kb-accept-entry 'Return,KP_Enter,Right'", source)
        self.assertIn("-kb-cancel 'Escape,Left'", source)
        self.assertIn('theme.model.normal)\") exec sh', source)
        self.assertIn('theme.model.float)\") exec sh', source)

    def test_theme_menu_releases_rofi_arrow_bindings(self):
        switcher = (self.system / "appearance/sh/theme-switch.sh").read_text()
        self.assertIn("theme-menu.sh", switcher)
        self.assertNotIn("-kb-custom-1 Right", switcher)

    def test_theme_switch_is_silent_on_success(self):
        result = self.apply("argvus-dark-aether")
        self.assertEqual(result.stdout, "")

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
        for edge in ("top", "left", "right", "bottom"):
            self.assertIn(f'"margin-{edge}": 0', bar)
        spaces_status = subprocess.run(
            ["sh", str(self.system / "hyprland/sh/spaces-switch.sh"), "--status"],
            env=self.env, capture_output=True, text=True, check=True,
        ).stdout
        self.assertIn("gaps_in=1", spaces_status)
        for edge in ("top", "left", "right", "bottom"):
            self.assertIn(f"gaps_out_{edge}=1", spaces_status)

        self.apply("argvus-light-veil-float")
        bar = (self.user / "waybar/argvus-taskbar.jsonc").read_text()
        for edge in ("top", "left", "right"):
            self.assertIn(f'"margin-{edge}": 16', bar)
        self.assertIn('"margin-bottom": 0', bar)
        float_spaces_status = subprocess.run(
            ["sh", str(self.system / "hyprland/sh/spaces-switch.sh"), "--status"],
            env=self.env, capture_output=True, text=True, check=True,
        ).stdout
        self.assertIn("gaps_in=8", float_spaces_status)
        for edge in ("top", "left", "right", "bottom"):
            self.assertIn(f"gaps_out_{edge}=8", float_spaces_status)

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
        # The top taskbar owns the top edge. Hyprland must not add the
        # configured window top gap to the taskbar bottom margin.
        self.assertIn(["hyprctl", "keyword", "general:gaps_out", "0 5 7 4"], self.commands())

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


if __name__ == "__main__":
    unittest.main()
