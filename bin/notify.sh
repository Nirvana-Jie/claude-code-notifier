#!/bin/bash
# Claude Code Notifier - macOS notification script
# https://github.com/Nirvana-Jie/claude-code-notifier

INPUT=$(cat)
TITLE="Claude Code"
SOUND="Ping"

# Parse JSON and generate message (use base64 to avoid injection)
INPUT_B64=$(echo -n "$INPUT" | base64)
MESSAGE=$(python3 -c "
import json
import base64
import sys
try:
    data = json.loads(base64.b64decode('$INPUT_B64').decode('utf-8'))
    event = data.get('hook_event_name', '')
    ntype = data.get('notification_type', '')

    if event == 'PermissionRequest':
        tool = data.get('tool_name', '')
        inp = data.get('tool_input', {})

        if tool in ['Edit', 'Write']:
            f = inp.get('file_path', '').split('/')[-1]
            print(f'Do you want to make this edit to {f}?')
        elif tool == 'Bash':
            cmd = inp.get('command', '')
            desc = inp.get('description', '')
            print(desc[:60] if desc else f'Run: {cmd[:50]}' + ('...' if len(cmd) > 50 else ''))
        elif tool == 'Read':
            f = inp.get('file_path', '').split('/')[-1]
            print(f'Read {f}?')
        elif tool == 'Task':
            print(f\"Task: {inp.get('description', 'subtask')[:50]}\")
        elif tool == 'WebFetch':
            print(f\"Fetch: {inp.get('url', '')[:45]}\")
        elif tool == 'WebSearch':
            print(f\"Search: {inp.get('query', '')[:45]}\")
        else:
            print(f'Allow {tool}?')

    elif event == 'Notification':
        if ntype == 'permission_prompt':
            print('__SKIP__')  # Handled by PermissionRequest
        else:
            msg = data.get('message', '')
            print(msg[:60] if msg else ('Claude is waiting for input' if ntype == 'idle_prompt' else 'Claude needs attention'))
    else:
        print('Action required')
except:
    print('Action required')
" 2>/dev/null)

[[ "$MESSAGE" == "__SKIP__" ]] && exit 0

# Detect terminal
case "$TERM_PROGRAM" in
    "iTerm.app")      TID="com.googlecode.iterm2" ;;
    "Apple_Terminal") TID="com.apple.Terminal" ;;
    "vscode")         TID="com.microsoft.VSCode" ;;
    "cursor")         TID="com.todesktop.230313mzl4w4u92" ;;
    "WarpTerminal")   TID="dev.warp.Warp-Stable" ;;
    "Hyper")          TID="co.zeit.hyper" ;;
    "Alacritty")      TID="org.alacritty" ;;
    "kitty")          TID="net.kovidgoyal.kitty" ;;
    "Tabby")          TID="org.tabby" ;;
    "WezTerm")        TID="com.github.wez.wezterm" ;;
    *)                TID="com.apple.Terminal" ;;
esac

# Send notification
if command -v terminal-notifier &> /dev/null; then
    terminal-notifier -title "$TITLE" -message "$MESSAGE" -sound "$SOUND" -activate "$TID"
else
    osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\" sound name \"$SOUND\""
fi
