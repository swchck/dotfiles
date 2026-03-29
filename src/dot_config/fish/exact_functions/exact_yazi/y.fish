# Description: Yazi file manager with cd-on-exit
# When you quit yazi, the shell cd's to the directory you navigated to
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and test -n "$cwd"; and test "$cwd" != (pwd)
        cd "$cwd"
    end
    command rm -f -- "$tmp"
end
