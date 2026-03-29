# Description: Create a temporary directory and cd into it
function tmpdir
    set -l dir (command mktemp -d)
    cd $dir
    echo $dir
end
