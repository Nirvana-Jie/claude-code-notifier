#!/bin/bash
# Claude Code Notifier - Installation Script
# https://github.com/Nirvana-Jie/claude-code-notifier

set -e

# Support non-interactive mode for Homebrew
NONINTERACTIVE=${NONINTERACTIVE:-0}
[[ "$1" == "-y" || "$1" == "--yes" ]] && NONINTERACTIVE=1

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Determine script location (handles both direct run and Homebrew)
if [[ -n "$HOMEBREW_PREFIX" ]]; then
    NOTIFY_SCRIPT="$HOMEBREW_PREFIX/bin/claude-code-notify"
else
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    NOTIFY_SCRIPT="$SCRIPT_DIR/bin/notify.sh"
fi

CLAUDE_SETTINGS="$HOME/.claude/settings.json"

echo "Claude Code Notifier"
echo "===================="
echo ""

# Check notify script
if [[ ! -f "$NOTIFY_SCRIPT" ]]; then
    echo -e "${RED}Error: notify script not found${NC}"
    exit 1
fi
chmod +x "$NOTIFY_SCRIPT" 2>/dev/null || true

# Install terminal-notifier (skip in non-interactive mode - Homebrew handles deps)
if [[ "$NONINTERACTIVE" != "1" ]] && ! command -v terminal-notifier &> /dev/null; then
    echo -e "${YELLOW}terminal-notifier not found${NC}"
    echo "Without it, clicking notifications won't activate your terminal."
    echo ""
    read -p "Install via Homebrew? [Y/n] " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        command -v brew &> /dev/null && brew install terminal-notifier
    fi
fi

# Configure Claude hooks
mkdir -p "$HOME/.claude"
[[ -f "$CLAUDE_SETTINGS" ]] && cp "$CLAUDE_SETTINGS" "$CLAUDE_SETTINGS.backup" 2>/dev/null || true

python3 << PYTHON
import json
from pathlib import Path

path = Path("$CLAUDE_SETTINGS")
try:
    settings = json.loads(path.read_text()) if path.exists() and path.stat().st_size > 0 else {}
except:
    settings = {}

settings["hooks"] = {
    "PermissionRequest": [{
        "matcher": "",
        "hooks": [{"type": "command", "command": "$NOTIFY_SCRIPT"}]
    }],
    "Notification": [{
        "matcher": "",
        "hooks": [{"type": "command", "command": "$NOTIFY_SCRIPT"}]
    }]
}

path.write_text(json.dumps(settings, indent=2))
PYTHON

echo -e "${GREEN}Installed!${NC}"
echo ""
echo "Notifications enabled for:"
echo "  • Permission requests (file edits, commands)"
echo "  • Idle prompts"
echo ""
echo "Test: $NOTIFY_SCRIPT"
