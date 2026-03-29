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

end
