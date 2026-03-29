#!/usr/bin/env sh

# Interactive commit browser between two refs/tags with diff preview via bat or less.
# Usage:
#   tagbrowse.sh <from_tag> <to_tag> [path]
# Requirements: fzf (mandatory), bat (optional; falls back to less)

set -eu

if ! command -v fzf >/dev/null 2>&1; then
  echo "fzf is required"
  exit 1
fi

if command -v bat >/dev/null 2>&1; then
  DEFAULT_PAGER="bat -l diff --color=always --style=plain"
else
  DEFAULT_PAGER="${PAGER:-less -R}"
fi

FROM="${1:?usage: tagbrowse.sh <from_tag> <to_tag> [path]}"
TO="${2:?usage: tagbrowse.sh <from_tag> <to_tag> [path]}"

PATH_FILTER="${3:-}"

if [ -n "$PATH_FILTER" ]; then
  COMMITS=$(git log --no-merges --date=short --pretty='%h %ad %an %s' "$FROM..$TO" -- "$PATH_FILTER")
else
  COMMITS=$(git log --no-merges --date=short --pretty='%h %ad %an %s' "$FROM..$TO")
fi

if [ -z "${COMMITS:-}" ]; then
  echo "No commits between $FROM and $TO"
  exit 0
fi

SEL=$(printf "%s\n" "$COMMITS" | \
  fzf --ansi --no-sort --tac \
      --prompt="Commits $FROM..$TO > " \
      --header='Enter: view diff | Ctrl-y: copy SHA | Ctrl-o: open in pager | ESC: cancel' \
      --bind 'enter:accept' \
      --bind 'ctrl-y:execute-silent(echo {1} | if command -v pbcopy >/dev/null 2>&1; then pbcopy; elif command -v xclip >/dev/null 2>&1; then xclip -selection clipboard; elif command -v clip >/dev/null 2>&1; then clip; fi)+refresh-preview' \
      --bind "ctrl-o:execute(git show --stat --patch --color=always {1} | ${PAGER:-$DEFAULT_PAGER})" \
      --preview "git show --stat --patch --color=always {1} | ${DEFAULT_PAGER}" \
      --preview-window=right:70%:wrap )

if [ -z "${SEL:-}" ]; then
  exit 0
fi

SHA=$(echo "$SEL" | awk '{print $1}')

git show --stat --patch --color=always "$SHA" | $DEFAULT_PAGER
