# Description: Filter which commands are saved to fish history (fish 4.0+).
# Returns 0 to store the command, non-zero to skip it. Atuin remains the primary
# history backend; this keeps secrets and noise out of fish's builtin history.
function fish_should_add_to_history
    set -l cmd "$argv"
    # Skip commands whose token likely carries a secret.
    if string match -qr -- '(-{1,2}password|-{1,2}token|API[_-]?KEY|SECRET|Bearer )' $cmd
        return 1
    end
    return 0
end
