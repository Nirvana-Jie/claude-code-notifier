# Claude Code Notifier

macOS notifications for [Claude Code](https://claude.ai/code) - get notified when Claude needs your input.

## Features

- 🔔 System notifications when Claude needs approval or input
- 🖱️ Click notification to return to terminal
- 📝 Shows specific action: "Do you want to make this edit to config.js?"
- 🖥️ Supports: iTerm2, Terminal.app, VS Code, Cursor, Warp, Hyper, Alacritty, kitty, Tabby, WezTerm
- 🔒 Script signature verification for security

## Installation

### Homebrew (Recommended)

```bash
brew tap Nirvana-Jie/cctools
brew install claude-code-notifier
```

### Manual

```bash
git clone https://github.com/Nirvana-Jie/claude-code-notifier.git
cd claude-code-notifier
./install.sh
```

## Update

```bash
brew upgrade claude-code-notifier
```

Or for manual installation:

```bash
cd claude-code-notifier
git pull
./install.sh
```

## Uninstall

```bash
brew uninstall claude-code-notifier
# or for manual installation
./uninstall.sh
```

## Quick Test

After installation, test immediately:

```bash
# For Homebrew installation
echo '{"hook_event_name":"Notification","notification_type":"idle_prompt"}' | claude-code-notify

# For manual installation (run from project directory)
echo '{"hook_event_name":"Notification","notification_type":"idle_prompt"}' | ./bin/notify.sh

# Or run Claude and ask it to create a file
claude
> Create a file called test.txt
```

Switch to another app - you'll receive a notification when Claude needs approval.

## How It Works

Uses Claude Code's [hooks system](https://code.claude.com/docs/en/hooks):

| Hook | Trigger |
|------|---------|
| `PermissionRequest` | File edits, bash commands, web requests |
| `Notification` | Idle timeout, other alerts |

## Notification Examples

| Action | Notification |
|--------|--------------|
| Edit file | "Do you want to make this edit to app.js?" |
| Run command | "Run: npm install" |
| Read file | "Read config.json?" |
| Subtask | "Task: analyze the codebase" |
| Web fetch | "Fetch: https://api.example.com" |
| Web search | "Search: python async tutorial" |
| Idle | "Claude is waiting for input" |

## Supported Terminals

| Terminal | Click to Activate |
|----------|-------------------|
| iTerm2 | ✅ |
| Terminal.app | ✅ |
| VS Code | ✅ |
| Cursor | ✅ |
| Warp | ✅ |
| Hyper | ✅ |
| Alacritty | ✅ |
| kitty | ✅ |
| Tabby | ✅ |
| WezTerm | ✅ |

> **Note**: Click-to-activate requires `terminal-notifier`. Without it, notifications still work but clicking won't focus the terminal.

## Requirements

- macOS
- [Claude Code](https://claude.ai/code) CLI
- Python 3

## Troubleshooting

### Notifications not appearing?

1. Check System Settings → Notifications → Script Editor (or terminal-notifier)
2. Ensure notifications are enabled

### Click doesn't activate terminal?

Install terminal-notifier:

```bash
brew install terminal-notifier
```

### Reinstalling after path change?

The installer automatically updates existing hooks when paths change (e.g., switching from manual to Homebrew installation).

## License

MIT
