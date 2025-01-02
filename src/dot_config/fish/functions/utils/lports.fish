# Desc: List all listening ports on the system
# TODO: fixit make tool agnostic
function lports
    lsof -i -P -n | grep LISTEN
end
