# Description: Interactive ripgrep with fzf preview (live grep)
# Usage: rgi [initial-query]
function rgi
    set -l query "$argv"
    set -l rg_cmd "rg --column --line-number --no-heading --color=always --smart-case"

    fzf --ansi --disabled --query "$query" \
        --bind "start:reload:$rg_cmd {q} || true" \
        --bind "change:reload:sleep 0.1; $rg_cmd {q} || true" \
        --delimiter : \
        --preview "bat --color=always {1} --highlight-line {2}" \
        --preview-window "up,60%,border-bottom,+{2}+3/3,~3" \
        --bind "enter:become($EDITOR {1} +{2})"
end
