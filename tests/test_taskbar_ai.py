"""Regression coverage for optional AI module preservation during projection."""
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest

PROJECT = Path(__file__).resolve().parents[1]
TEMPLATE = PROJECT.parent / "argvus-taskbar/src/usr/share/argvus/taskbar/config/argvus-taskbar.jsonc"
SCRIPT = PROJECT / "src/usr/share/argvus/appearance/sh/taskbar-widgets-mode.sh"

class Projection(unittest.TestCase):
    def test_ai_survives_repeated_projection_and_disabled_utilities(self):
        Path("/tmp/argvus").mkdir(exist_ok=True)
        with tempfile.TemporaryDirectory(dir="/tmp/argvus") as directory:
            root = Path(directory)
            target = root / "taskbar.jsonc"
            # Simulate a generated configuration from before Update Status existed.
            old_config = re.sub(r'  "custom/update-status": \{.*?^  \},\n', '', TEMPLATE.read_text(), flags=re.MULTILINE | re.DOTALL)
            old_config = re.sub(r'  "group/update-status": \{.*?^  \},\n', '', old_config, flags=re.MULTILINE | re.DOTALL)
            target.write_text(old_config)
            bootstrap = root / "bootstrap.sh"
            bootstrap.write_text('paths_system_config() { printf "%s\\n" "$TEMPLATE"; }\npaths_config() { printf "%s\\n" "$TARGET"; }\n')
            binary = root / "argvus"
            binary.write_text('#!/bin/sh\ncase "$3" in /taskbar/icons/update_status_enabled) printf "%s" "${AI_ENABLED:-true}" ;; /taskbar/icons/ai_agents_enabled) printf "%s" "${AI_ENABLED:-true}" ;; /taskbar/icons/utilities/expanded) printf "%s" "${EXPANDED:-true}" ;; /taskbar/icons/notifications_enabled|/taskbar/icons/removable_devices_enabled|/taskbar/icons/recording_enabled|/taskbar/icons/bluetooth_enabled|/taskbar/icons/audio_input_enabled|/taskbar/icons/audio_output_enabled|/taskbar/icons/keep_awake_enabled) printf "%s" "${UTILITIES:-true}" ;; *) exit 1 ;; esac\n')
            binary.chmod(0o755)
            env = dict(os.environ, ARGVUS_BOOTSTRAP=str(bootstrap), ARGVUS_CONFIG_HOME=directory, TEMPLATE=str(TEMPLATE), TARGET=str(target), PATH=directory + ":/usr/bin:/bin")
            for expanded, utilities, ai in [(e, u, a) for e in ["true", "false"] for u in ["true", "false"] for a in ["true", "false"]]:
                env.update(EXPANDED=expanded, UTILITIES=utilities, AI_ENABLED=ai)
                for _ in range(2):
                    result = subprocess.run(["sh", str(SCRIPT), "apply"], env=env, capture_output=True, text=True)
                    self.assertEqual(result.returncode, 0, result.stderr)
                    text = re.sub(r"^\s*//.*$", "", target.read_text(), flags=re.MULTILINE)
                    data = json.loads(text)
                    self.assertIn("custom/update-status", data)
                    self.assertNotIn("custom/update-status", data["group/right-1"]["modules"])
                    self.assertEqual(data["group/update-status"]["modules"], ["custom/update-status"])
                    self.assertEqual("group/update-status" in data["modules-right"], ai == "true")
                    if ai == "true" and utilities == "true":
                        right = data["modules-right"]
                        self.assertEqual(right.index("group/update-status"), right.index("group/right-2") + 1)
                        self.assertEqual(right.index("group/right-1"), right.index("group/update-status") + 1)
                    self.assertIn("font_family='Symbols Nerd Font Mono'", data["custom/update-status"]["format"])
                    modules = data["group/right-2"]["modules"]
                    self.assertEqual(modules.count("custom/window-mode"), 1)
                    self.assertEqual(modules.count("custom/ai"), int(ai == "true"))
                    self.assertEqual("group/right-2" in data["modules-right"], True)
                    self.assertEqual("pulseaudio#input" in modules, utilities == "true")
                    self.assertEqual("pulseaudio#output" in modules, utilities == "true")
                    self.assertEqual("custom/right-2-expander" in modules, expanded == "false")


class ClockProjection(unittest.TestCase):
    def test_clock_format_and_interval_for_each_time_setting(self):
        Path("/tmp/argvus").mkdir(exist_ok=True)
        with tempfile.TemporaryDirectory(dir="/tmp/argvus") as directory:
            root = Path(directory)
            target = root / "taskbar.jsonc"
            target.write_text(TEMPLATE.read_text())
            bootstrap = root / "bootstrap.sh"
            bootstrap.write_text('paths_system_config() { printf "%s\\n" "$TEMPLATE"; }\npaths_config() { printf "%s\\n" "$TARGET"; }\n')
            binary = root / "argvus"
            binary.write_text('#!/bin/sh\ncase "$3" in /taskbar/time/format) printf "%s" "$TIME_FORMAT" ;; /taskbar/time/seconds_enabled) printf "%s" "$SECONDS_ENABLED" ;; *) exit 1 ;; esac\n')
            binary.chmod(0o755)
            env = dict(os.environ, ARGVUS_BOOTSTRAP=str(bootstrap), ARGVUS_CONFIG_HOME=directory,
                       TEMPLATE=str(TEMPLATE), TARGET=str(target), PATH=directory + ":/usr/bin:/bin")
            for time_format, seconds, expected, interval in [
                ("24h", "false", "%H:%M", 60), ("24h", "true", "%H:%M:%S", 1),
                ("12h", "false", "%I:%M %p", 60), ("12h", "true", "%I:%M:%S %p", 1),
            ]:
                with self.subTest(time_format=time_format, seconds=seconds):
                    env.update(TIME_FORMAT=time_format, SECONDS_ENABLED=seconds)
                    result = subprocess.run(["sh", str(SCRIPT), "apply"], env=env, capture_output=True, text=True)
                    self.assertEqual(result.returncode, 0, result.stderr)
                    text = re.sub(r"^\s*//.*$", "", target.read_text(), flags=re.MULTILINE)
                    clock = json.loads(text)["clock#time"]
                    self.assertEqual(clock["format"], f"<span font_family='Symbols Nerd Font Mono'>󰅐</span> {{:L{expected}}}")
                    self.assertEqual(clock["interval"], interval)
                    self.assertIn("clock#time", json.loads(text)["group/right-0"]["modules"])


if __name__ == "__main__":
    unittest.main()
