# Description: Ctrl+Z toggles between suspend and resume (fg)
function ctrl_z_toggle
    if test (count (jobs)) -eq 0
        return
    end
    fg
    commandline -f repaint
end
