# Test Guide

Test notifications without global installation - just run `claude` in this directory.

## Quick Start

```bash
# 1. Install terminal-notifier (optional, for click-to-activate)
brew install terminal-notifier

# 2. Run verification
./test/verify.sh

# 3. Start Claude in this directory
claude

# 4. Switch to another app, then test with:
```

**Test prompt:** `Create a file called hello.txt`

You should receive a notification: "Do you want to make this edit to hello.txt?"

## Test Cases

| Prompt | Expected Notification |
|--------|----------------------|
| `Create a file called test.txt` | Do you want to make this edit to test.txt? |
| `Run: echo "hello"` | Run: echo "hello" |
| `Read the README.md file` | Read README.md? |
| `Fetch https://example.com` | Fetch: https://example.com |
| `Search for "Claude Code"` | Search: Claude Code |

## Troubleshooting

**No notification?**
- Check System Settings → Notifications → terminal-notifier

**Two notifications?**
- Clear global hooks: `echo '{}' > ~/.claude/settings.json`

**Click doesn't activate terminal?**
- Install: `brew install terminal-notifier`
