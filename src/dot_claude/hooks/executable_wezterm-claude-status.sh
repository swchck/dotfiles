#!/usr/bin/env bash
# Reports Claude Code's state to WezTerm as the `claude_status` user var so the
# tab bar can show a colored status dot (green=idle, yellow=waiting, blue=working).
#
# Wired from settings.json hooks:
#   UserPromptSubmit -> working   Stop/SessionStart -> idle
#   Notification(permission/elicitation/agent_needs_input) -> waiting
#   SessionEnd -> "" (clears the dot)
#
# Escape sequences are emitted via Claude Code's `terminalSequence` JSON output,
# NOT written to /dev/tty: since Claude Code 2.1.139 hooks run without a
# controlling terminal, so a direct /dev/tty write fails silently or corrupts
# the TUI. WezTerm's OSC 1337 SetUserVar requires a base64-encoded value.
state="${1:-}"
b64=$(printf '%s' "$state" | base64 | tr -d '\n')
printf '{"terminalSequence":"\\u001b]1337;SetUserVar=claude_status=%s\\u0007"}' "$b64"
