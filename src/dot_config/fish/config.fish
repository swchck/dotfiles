# Fish 4.5.0 interactive shell configuration
# Sourced only for interactive sessions

if status is-interactive

    # ── Starship Prompt ──────────────────────────────────────────────
    if command -q starship
        starship init fish | source

        # Transient prompt — show only character for previous commands
        if functions -q enable_transience
            function starship_transient_prompt_func
                starship module character
            end
            enable_transience
        end
    end

    # ── fzf ──────────────────────────────────────────────────────────
    if command -q fzf
        fzf --fish | source
    end

    # ── Atuin (shell history) ────────────────────────────────────────
    if command -q atuin
        atuin init fish | source
    end

    # ── Zoxide (smart cd) ────────────────────────────────────────────
    if command -q zoxide
        zoxide init fish | source
    end

    # ── Keybindings ─────────────────────────────────────────────────

    # Ctrl+Z: toggle suspend/resume (fg)
    bind ctrl-z 'if test (count (jobs)) -gt 0; fg; commandline -f repaint; end'

    # !! expansion: type !! then press Space to replace with last command
    function _expand_bang_bang
        set -l cmd (commandline)
        if string match -q -- "*!!" "$cmd"
            commandline -r (string replace "!!" "$history[1]" "$cmd")
            commandline -f repaint
        else
            commandline -i " "
        end
    end
    bind space _expand_bang_bang

end
