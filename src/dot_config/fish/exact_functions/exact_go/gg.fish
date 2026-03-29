# Description: go generate ./... (only in Go projects)
function gg
    if not test -f go.mod
        echo "Not a Go project (no go.mod)"
        return 1
    end
    go generate ./... $argv
end
