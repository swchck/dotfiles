# Auto-activate a project's .venv when entering its tree, deactivate on leaving.
# In conf.d (not functions/) so the --on-variable handler registers at startup
# rather than only after the function is first called by name.

function __auto_venv --on-variable PWD --description 'Toggle .venv activation as PWD changes'
    status is-interactive; or return

    set -l venv ''
    set -l dir $PWD
    while true
        if test -f "$dir/.venv/bin/activate.fish"
            set venv "$dir/.venv"
            break
        end
        test "$dir" = /; and break
        set dir (path dirname $dir)
    end

    if test -n "$venv"
        # switch only when it's a different venv than the active one
        if test "$VIRTUAL_ENV" != "$venv"
            type -q deactivate; and deactivate
            source "$venv/bin/activate.fish"
        end
    else if set -q VIRTUAL_ENV
        type -q deactivate; and deactivate
    end
end

# fire once so a shell started inside a project picks up its venv immediately
__auto_venv
