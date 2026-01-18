#!/bin/bash
# Quick verification script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NOTIFY="$SCRIPT_DIR/bin/notify.sh"

echo "Claude Code Notifier - Verify"
echo "=============================="
echo ""

# Check notify.sh
echo -n "1. notify.sh exists: "
[[ -f "$NOTIFY" ]] && echo "✓" || { echo "✗"; exit 1; }

# Check executable
echo -n "2. notify.sh executable: "
[[ -x "$NOTIFY" ]] && echo "✓" || { chmod +x "$NOTIFY"; echo "✓ (fixed)"; }

# Check terminal-notifier
echo -n "3. terminal-notifier: "
command -v terminal-notifier &>/dev/null && echo "✓" || echo "✗ (install: brew install terminal-notifier)"

# Check project settings
echo -n "4. Project hooks configured: "
[[ -f "$SCRIPT_DIR/.claude/settings.json" ]] && grep -q "PermissionRequest" "$SCRIPT_DIR/.claude/settings.json" && echo "✓" || echo "✗"

# Send test notification
echo ""
echo "5. Sending test notification..."
echo '{"hook_event_name":"PermissionRequest","tool_name":"Write","tool_input":{"file_path":"/test/example.txt"}}' | "$NOTIFY"
echo "   ✓ Check your notifications!"

echo ""
echo "Next: Run 'claude' in this directory and test with prompts from test/README.md"
