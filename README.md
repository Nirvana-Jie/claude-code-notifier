# Claude Code Notifier

macOS notifications for [Claude Code](https://claude.ai/code) - get notified when Claude needs your input.

## Features

- 🔔 System notifications when Claude needs approval or input
- 🖱️ Click notification to return to terminal
- 📝 Shows specific action: "Do you want to make this edit to config.js?"
- 🖥️ Supports: iTerm2, Terminal.app, VS Code, Warp, Hyper, Alacritty, kitty

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

## Uninstall

```bash
brew uninstall claude-code-notifier
# or
./uninstall.sh
```

## Quick Test

After installation, test immediately:

```bash
# Send a test notification
claude-code-notify

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
| Web fetch | "Fetch: https://api.example.com" |

## Requirements

- macOS
- [Claude Code](https://claude.ai/code) CLI
- Python 3

## License

MIT
