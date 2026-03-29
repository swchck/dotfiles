# Description: go mod tidy (only in Go projects)
function gmt
    if not test -f go.mod
        echo "Not a Go project (no go.mod)"
        return 1
    end
    go mod tidy $argv
end
