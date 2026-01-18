# typed: false
# frozen_string_literal: true

# Homebrew formula for Claude Code Notifier
# https://github.com/Nirvana-Jie/claude-code-notifier
#
# Install: brew install Nirvana-Jie/tap/claude-code-notifier
# Or tap first: brew tap Nirvana-Jie/tap && brew install claude-code-notifier

class ClaudeCodeNotifier < Formula
  desc "macOS system notifications for Claude Code"
  homepage "https://github.com/Nirvana-Jie/claude-code-notifier"
  url "https://github.com/Nirvana-Jie/claude-code-notifier/archive/refs/tags/v0.0.1.tar.gz"
  sha256 "2ac670ee92d17c20d6bd7e42b50e2fb794ef3fd967f3a06f8e94f634ff0d7e29"
  license "MIT"

  depends_on :macos
  depends_on "python@3"
  depends_on "terminal-notifier" => :recommended

  def install
    # Install the main notification script to bin
    bin.install "bin/notify.sh" => "claude-code-notify"

    # Install management scripts to libexec (internal use)
    libexec.install "install.sh"
    libexec.install "uninstall.sh"

    # Make scripts executable
    chmod 0755, libexec/"install.sh"
    chmod 0755, libexec/"uninstall.sh"
  end

  def post_install
    # Configure hooks in non-interactive mode
    # The install.sh script will auto-detect HOMEBREW_PREFIX
    system libexec/"install.sh", "-y"
  end

  def caveats
    <<~EOS
      ✅ Hooks have been configured in ~/.claude/settings.json

      Test notification:
        echo '{"hook_event_name":"Notification","message":"Hello!"}' | claude-code-notify

      Restart Claude Code for changes to take effect.

      ⚠️  Before uninstalling, run:
        #{libexec}/uninstall.sh

      Or manually remove the hooks from ~/.claude/settings.json
    EOS
  end

  test do
    # Verify the script exists and contains the expected signature
    assert_predicate bin/"claude-code-notify", :exist?
    assert_match "claude-code-notifier", shell_output("cat #{bin}/claude-code-notify")

    # Verify management scripts are installed
    assert_predicate libexec/"install.sh", :exist?
    assert_predicate libexec/"uninstall.sh", :exist?
  end
end
