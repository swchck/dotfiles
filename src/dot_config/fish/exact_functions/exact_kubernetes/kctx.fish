# Description: Interactive kubectl context switcher using fzf
function kctx
    if test (count $argv) -gt 0
        kubectl config use-context $argv[1]
    else
        set -l ctx (kubectl config get-contexts -o name 2>/dev/null | fzf --header="Select context")
        if test -n "$ctx"
            kubectl config use-context $ctx
        end
    end
end
