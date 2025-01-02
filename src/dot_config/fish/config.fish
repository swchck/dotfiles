# This file is sourced by fish when it starts up. It should be used to set up
# environment variables such as PATH and MANPATH, and to run programs that should
# be run when fish starts.

# Description: on_interaction function will be called when fish starts interactively.
if status is-interactive

    # Set up starship prompt
    starship init fish | source

    # # Set up fzf key bindings
    fzf --fish | source

    # Install Atuin fish integration
    atuin init fish | source

    # Zoxide
    zoxide init fish | source

end

# Description: on_exit function will be called when fish exits.
# function on_exit --on-event fish_exit

# end
