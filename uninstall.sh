#!/bin/bash
# Claude Code Notifier - Uninstallation Script
# https://github.com/Nirvana-Jie/claude-code-notifier

set -e

# Support non-interactive mode for Homebrew
NONINTERACTIVE=${NONINTERACTIVE:-0}
[[ "$1" == "-y" || "$1" == "--yes" ]] && NONINTERACTIVE=1

# Colors for output (disable in non-interactive mode for cleaner logs)
if [[ "$NONINTERACTIVE" == "1" ]]; then
    RED=''
    GREEN=''
    YELLOW=''
    NC=''
else
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m'
fi

CLAUDE_SETTINGS="$HOME/.claude/settings.json"

echo "Claude Code Notifier - Uninstallation"
echo "======================================"
echo ""

if [[ ! -f "$CLAUDE_SETTINGS" ]]; then
    echo "No Claude settings file found. Nothing to uninstall."
    exit 0
fi

# Remove only notifier hooks from settings using Python
python3 << 'PYTHON'
import json
import sys
import os

settings_path = os.path.expanduser("~/.claude/settings.json")

try:
    with open(settings_path, "r") as f:
        settings = json.load(f)
except (json.JSONDecodeError, FileNotFoundError):
    print("No valid settings found.")
    sys.exit(0)

if "hooks" not in settings:
    print("No hooks found in settings.")
    sys.exit(0)

# Identifiers for notifier hooks
notifier_identifiers = ["claude-code-notify", "notify.sh"]

def is_notifier_hook(hook_config):
    """Check if a hook config contains notifier command."""
    for hook in hook_config.get("hooks", []):
        command = hook.get("command", "")
        if any(identifier in command for identifier in notifier_identifiers):
            return True
    return False

modified = False
for hook_type in list(settings["hooks"].keys()):
    original_count = len(settings["hooks"][hook_type])
    # Filter out notifier hooks, keep others
    settings["hooks"][hook_type] = [
        h for h in settings["hooks"][hook_type] if not is_notifier_hook(h)
    ]
    new_count = len(settings["hooks"][hook_type])

    if new_count < original_count:
        modified = True

    # Remove empty hook type
    if not settings["hooks"][hook_type]:
        del settings["hooks"][hook_type]

# Remove empty hooks object
if not settings["hooks"]:
    del settings["hooks"]

if modified:
    with open(settings_path, "w") as f:
        # Write with consistent formatting (preserve unicode, add trailing newline)
        f.write(json.dumps(settings, indent=2, ensure_ascii=False) + "\n")
    print("Removed notifier hooks from Claude settings.")
else:
    print("No notifier hooks found in settings.")
PYTHON

echo ""
echo -e "${GREEN}Uninstallation complete!${NC}"
echo ""
if [[ -f "$CLAUDE_SETTINGS.backup" ]]; then
    echo "You can restore your original settings from:"
    echo "  $CLAUDE_SETTINGS.backup"
fi
