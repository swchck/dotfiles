function __uv_pip_guard --description 'Redirect global pip/pip3 to uv; pass through inside a venv'
    set -l bin $argv[1]
    set -l args $argv[2..-1]

    # inside an active venv pip is the correct tool — hand off to the real binary
    if set -q VIRTUAL_ENV
        command $bin $args
        return $status
    end

    set -l sub $args[1]
    set -l pkgs
    for a in $args[2..-1]
        string match -q -- '-*' $a; or set -a pkgs $a
    end

    # parallel arrays: cmds[i] is executed, labels[i] is shown in the picker
    set -l cmds
    set -l labels
    switch $sub
        case install
            if contains -- -r $args; or contains -- --requirement $args
                set -l f requirements.txt
                set -l take 0
                for a in $args
                    test $take -eq 1; and set f $a; and break
                    string match -q -- -r $a; or string match -q -- --requirement $a; and set take 1
                end
                set -a cmds "uv pip install -r $f"; set -a labels "uv pip install -r $f  ·  into an activated venv"
                set -a cmds "uv add -r $f"; set -a labels "uv add -r $f  ·  into the current project"
            else if test (count $pkgs) -gt 0
                set -a cmds "uv add $pkgs"; set -a labels "uv add $pkgs  ·  project dependency"
                set -a cmds "uv tool install $pkgs"; set -a labels "uv tool install $pkgs  ·  standalone CLI app"
                set -a cmds "uvx $pkgs[1]"; set -a labels "uvx $pkgs[1]  ·  run once, no install"
            end
        case uninstall
            if test (count $pkgs) -gt 0
                set -a cmds "uv remove $pkgs"; set -a labels "uv remove $pkgs  ·  drop a project dependency"
                set -a cmds "uv tool uninstall $pkgs"; set -a labels "uv tool uninstall $pkgs  ·  remove a CLI app"
            end
        case list freeze
            set -a cmds "uv tool list"; set -a labels "uv tool list  ·  installed CLI apps"
            set -a cmds "uv pip list"; set -a labels "uv pip list  ·  packages in an activated venv"
    end

    set_color yellow
    echo "$bin global is off — PEP 668 blocks it and it pollutes the system python."
    set_color normal

    if test (count $cmds) -eq 0
        echo "  reach for: uv add / uv tool install / uvx / uv venv / uv pip"
        return 1
    end

    # no fzf → fall back to a plain printed list
    if not command -q fzf
        for l in $labels
            echo "  $l"
        end
        return 1
    end

    set -l pick (printf '%s\n' $labels | fzf --layout=reverse --height=~40% --border \
        --prompt='pip→uv › ' --header="$bin $args" --no-multi)
    test -z "$pick"; and return 130

    for i in (seq (count $labels))
        if test "$labels[$i]" = "$pick"
            set_color cyan
            echo "» $cmds[$i]"
            set_color normal
            eval $cmds[$i]
            return $status
        end
    end
end
