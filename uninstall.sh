#!/bin/bash
# Claude Code Notifier - Uninstallation Script
# https://github.com/Nirvana-Jie/claude-code-notifier

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

CLAUDE_SETTINGS="$HOME/.claude/settings.json"

echo "Claude Code Notifier - Uninstallation"
echo "======================================"
echo ""

if [[ ! -f "$CLAUDE_SETTINGS" ]]; then
    echo "No Claude settings file found. Nothing to uninstall."
    exit 0
fi

# Remove hooks from settings using Python
python3 << 'PYTHON'
import json
import sys

settings_path = "$HOME/.claude/settings.json".replace("$HOME", __import__("os").environ["HOME"])

try:
    with open(settings_path, "r") as f:
        settings = json.load(f)
except (json.JSONDecodeError, FileNotFoundError):
    print("No valid settings found.")
    sys.exit(0)

if "hooks" in settings:
    del settings["hooks"]
    with open(settings_path, "w") as f:
        json.dump(settings, f, indent=2)
    print("Removed hooks from Claude settings.")
else:
    print("No hooks found in settings.")
PYTHON

echo ""
echo -e "${GREEN}Uninstallation complete!${NC}"
echo ""
echo "You can restore your previous settings from:"
echo "  $CLAUDE_SETTINGS.backup"
