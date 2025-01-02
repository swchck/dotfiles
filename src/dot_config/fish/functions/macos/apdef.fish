# TODO: fixit

# Convert `defaults read` output to JSON
#
# Input: $1 - Data from "defaults read" command
# Output: JSON representation of the input data

function apdef
    defaults read >defaults.txt
end
