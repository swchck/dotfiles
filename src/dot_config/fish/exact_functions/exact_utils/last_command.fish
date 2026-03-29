# Description: !! — repeat last command, sudo !! — repeat with sudo
function last_command
    switch (commandline)
        case "!!"
            commandline -r $history[1]
        case "sudo !!"
            commandline -r "sudo $history[1]"
        case "*!!"
            set -l cmd (commandline)
            set -l replaced (string replace "!!" $history[1] $cmd)
            commandline -r $replaced
    end
end
