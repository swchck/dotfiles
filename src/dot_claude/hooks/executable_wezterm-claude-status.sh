#!/usr/bin/env bash
# Reports Claude Code's state to WezTerm as the `claude_status` user var so the
# tab bar can tint the claude icon (green=idle, yellow=waiting on you, blue=working).
#
# Wired from settings.json hooks:
#   UserPromptSubmit, PostToolUse -> working   (active work)
#   PreToolUse(AskUserQuestion|ExitPlanMode) -> waiting   (fires the instant a
#       dialog is about to show — instant, unlike Notification which debounces)
#   Notification(permission_prompt|elicitation_dialog) -> waiting  (fallback for
#       permission dialogs, ~2s late due to Claude Code's notification debounce)
#   Stop, SessionStart -> idle                 SessionEnd -> "" (clear)
#
# Delivery: hooks run detached (no controlling tty) and Claude Code's
# `terminalSequence` field doesn't reach the terminal in this version. But
# WEZTERM_PANE is exported and `wezterm cli list` reports each pane's tty_name,
# so we write the OSC 1337 SetUserVar straight to that tty device (WezTerm, the
# pty master, then processes it). The tty is cached per pane so the common path
# needs no `wezterm cli` call — cheap enough to run on every tool use. WezTerm
# needs the value base64-encoded; SetUserVar is non-display so the TUI is safe.
state="${1:-}"
[ -n "$WEZTERM_PANE" ] || exit 0
b64=$(printf '%s' "$state" | base64 | tr -d '\n')

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/wezterm-claude"
cache="$cache_dir/pane-$WEZTERM_PANE"
tty_dev=""
[ -r "$cache" ] && tty_dev=$(cat "$cache" 2>/dev/null)

if [ -z "$tty_dev" ] || [ ! -w "$tty_dev" ]; then
    command -v wezterm >/dev/null 2>&1 || exit 0
    tty_dev=$(wezterm cli list --format json 2>/dev/null | WP="$WEZTERM_PANE" python3 -c '
import sys, json, os
want = int(os.environ["WP"])
try:
    for p in json.load(sys.stdin):
        if p.get("pane_id") == want:
            sys.stdout.write(p.get("tty_name") or ""); break
except Exception:
    pass
' 2>/dev/null)
    [ -n "$tty_dev" ] && { mkdir -p "$cache_dir" 2>/dev/null; printf '%s' "$tty_dev" > "$cache" 2>/dev/null; }
fi

[ -n "$tty_dev" ] && [ -w "$tty_dev" ] && \
    printf '\033]1337;SetUserVar=claude_status=%s\007' "$b64" > "$tty_dev" 2>/dev/null
