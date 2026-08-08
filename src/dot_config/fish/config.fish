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
    # --cmd cd generates zoxide-backed `cd`/`cdi` (replaces the old cd.fish
    # wrapper, which had a dead branch and no `cd -` support).
    if command -q zoxide
        zoxide init fish --cmd cd | source

        # Keep the classic `z`/`zi` names too — `--cmd cd` renames them to
        # `cd`/`cdi`, so wrap the internal functions to restore muscle memory.
        function z --wraps __zoxide_z --description 'zoxide: jump to a directory'
            __zoxide_z $argv
        end
        function zi --wraps __zoxide_zi --description 'zoxide: interactive jump'
            __zoxide_zi $argv
        end
    end

    # ── Keybindings ─────────────────────────────────────────────────

    # Ctrl+Z: toggle suspend/resume (fg) — see functions/utils/ctrl_z_toggle.fish
    bind ctrl-z ctrl_z_toggle

    # Token-wise navigation/editing (fish 4.1+) — like word motions but by shell token
    bind ctrl-alt-f forward-token
    bind ctrl-alt-b backward-token
    bind ctrl-alt-w backward-kill-token

    # !! expansion is handled by the `!!` abbr in functions/utils/last_history_item.fish.
    # (An earlier `bind space` handler was removed — it broke abbr expansion on space.)

    # ── Abbreviations ────────────────────────────────────────────────
    # Command-scoped git abbreviations (fish 4.0+): expand only after `git `,
    # so they never collide as a first word.
    abbr --add --command git st status
    abbr --add --command git co checkout
    abbr --add --command git br branch
    abbr --add --command git cm commit

end
