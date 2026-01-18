#!/bin/bash
# Claude Code Notifier - Installation Script
# https://github.com/Nirvana-Jie/claude-code-notifier

set -e

# Support non-interactive mode for Homebrew
NONINTERACTIVE=${NONINTERACTIVE:-0}
[[ "$1" == "-y" || "$1" == "--yes" ]] && NONINTERACTIVE=1

# Auto-detect HOMEBREW_PREFIX if not set
if [[ -z "$HOMEBREW_PREFIX" ]]; then
    if [[ -x "/opt/homebrew/bin/brew" ]]; then
        HOMEBREW_PREFIX="/opt/homebrew"
    elif [[ -x "/usr/local/bin/brew" ]]; then
        HOMEBREW_PREFIX="/usr/local"
    fi
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Determine script location (handles both direct run and Homebrew)
# Priority: 1. Local script (most trusted) 2. Homebrew installed binary
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Signature to verify authentic notify script
NOTIFY_SIGNATURE="github.com/Nirvana-Jie/claude-code-notifier"

verify_notify_script() {
    local script="$1"
    [[ -x "$script" ]] && grep -q "$NOTIFY_SIGNATURE" "$script" 2>/dev/null
}

if [[ -f "$SCRIPT_DIR/bin/notify.sh" ]] && verify_notify_script "$SCRIPT_DIR/bin/notify.sh"; then
    # Running from source directory (most trusted)
    NOTIFY_SCRIPT="$SCRIPT_DIR/bin/notify.sh"
elif [[ -n "$HOMEBREW_PREFIX" ]] && verify_notify_script "$HOMEBREW_PREFIX/bin/claude-code-notify"; then
    # Running from Homebrew installation
    NOTIFY_SCRIPT="$HOMEBREW_PREFIX/bin/claude-code-notify"
elif verify_notify_script "/opt/homebrew/bin/claude-code-notify"; then
    # Fallback: Apple Silicon Homebrew
    NOTIFY_SCRIPT="/opt/homebrew/bin/claude-code-notify"
elif verify_notify_script "/usr/local/bin/claude-code-notify"; then
    # Fallback: Intel Homebrew
    NOTIFY_SCRIPT="/usr/local/bin/claude-code-notify"
else
    echo -e "${RED}Error: notify script not found or signature verification failed${NC}"
    echo "Please run from source directory or install via Homebrew."
    exit 1
fi

CLAUDE_SETTINGS="$HOME/.claude/settings.json"

echo "Claude Code Notifier"
echo "===================="
echo ""
echo "Using notify script: $NOTIFY_SCRIPT"
echo ""

# Verify notify script is executable
if [[ ! -x "$NOTIFY_SCRIPT" ]]; then
    chmod +x "$NOTIFY_SCRIPT" 2>/dev/null || {
        echo -e "${RED}Error: Cannot make notify script executable${NC}"
        exit 1
    }
fi

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
# Only backup if no backup exists (preserve original settings)
if [[ -f "$CLAUDE_SETTINGS" ]] && [[ ! -f "$CLAUDE_SETTINGS.backup" ]]; then
    cp "$CLAUDE_SETTINGS" "$CLAUDE_SETTINGS.backup" 2>/dev/null || true
fi

NOTIFY_SCRIPT="$NOTIFY_SCRIPT" CLAUDE_SETTINGS="$CLAUDE_SETTINGS" python3 << 'PYTHON'
import json
import os
from pathlib import Path

path = Path(os.environ["CLAUDE_SETTINGS"])
notify_script = os.environ["NOTIFY_SCRIPT"]

# Identifiers for detecting existing notifier hooks (handles path changes)
notifier_identifiers = ["claude-code-notify", "notify.sh"]

try:
    settings = json.loads(path.read_text()) if path.exists() and path.stat().st_size > 0 else {}
except:
    settings = {}

# Ensure hooks object exists
if "hooks" not in settings:
    settings["hooks"] = {}

def is_notifier_hook(hook):
    """Check if a hook is a notifier hook."""
    if hook.get("type") != "command":
        return False
    command = hook.get("command", "")
    return any(identifier in command for identifier in notifier_identifiers)

def add_notifier_hook(hook_type):
    """Add notifier hook to a hook type, preserving existing hooks."""
    notifier_hook = {
        "matcher": "",
        "hooks": [{"type": "command", "command": notify_script}]
    }

    if hook_type not in settings["hooks"]:
        settings["hooks"][hook_type] = [notifier_hook]
        return

    # Check if notifier hook already exists and update it
    for hook_config in settings["hooks"][hook_type]:
        for i, hook in enumerate(hook_config.get("hooks", [])):
            if is_notifier_hook(hook):
                # Update existing hook with new path
                hook_config["hooks"][i]["command"] = notify_script
                return

    # Append notifier hook to existing hooks
    settings["hooks"][hook_type].append(notifier_hook)

add_notifier_hook("PermissionRequest")
add_notifier_hook("Notification")

# Write with consistent formatting (preserve unicode, add trailing newline)
path.write_text(json.dumps(settings, indent=2, ensure_ascii=False) + "\n")
PYTHON

echo -e "${GREEN}Installed!${NC}"
echo ""
echo "Notifications enabled for:"
echo "  • Permission requests (file edits, commands)"
echo "  • Idle prompts"
echo ""
echo "Restart Claude Code for changes to take effect."
