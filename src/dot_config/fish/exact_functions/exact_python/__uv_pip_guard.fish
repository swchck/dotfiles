function __uv_pip_guard --description 'Redirect global pip/pip3 to uv; pass through inside a venv'
    set -l bin $argv[1]
    set -l args $argv[2..-1]

    # inside an active venv pip is the correct tool — hand off to the real binary
    if set -q VIRTUAL_ENV
        command $bin $args
        return $status
    end

    set_color yellow
    echo "$bin into the global interpreter is off — PEP 668 blocks it and it pollutes the system python."
    set_color normal

    set -l sub $args[1]
    set -l pkgs
    for a in $args[2..-1]
        string match -q -- '-*' $a; or set -a pkgs $a
    end

    switch $sub
        case install
            if contains -- -r $args; or contains -- --requirement $args
                echo "  uv pip install -r <file>   # into an activated venv"
                echo "  uv add -r <file>           # into the current project"
            else if test (count $pkgs) -gt 0
                echo "  uv add $pkgs        # add as a project dependency"
                echo "  uv tool install $pkgs   # install as a standalone CLI app"
                echo "  uvx $pkgs[1]            # run once, without installing"
            else
                echo "  uv add <pkg> / uv tool install <pkg> / uvx <pkg>"
            end
        case uninstall
            echo "  uv remove $pkgs         # drop a project dependency"
            echo "  uv tool uninstall $pkgs   # remove a CLI app"
        case list freeze
            echo "  uv tool list   # installed CLI apps"
            echo "  uv pip list    # packages in an activated venv"
        case '*'
            echo "  uv add / uv tool install / uvx / uv venv / uv pip"
    end

    echo "need a venv here?  uv venv; and source .venv/bin/activate.fish"
    return 1
end
