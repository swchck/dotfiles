# Set Welcome message to Null
# Default:
#   Welcome to fish, the friendly interactive shell
#   Type help for instructions on how to use fish
set fish_greeting ""

# Source functions from subdirectories
for file in ~/.config/fish/functions/**/*.fish
    source $file
end

# Set up Homebrew
eval (/opt/homebrew/bin/brew shellenv)

# # Set up Cargo bin directory
set PATH $PATH ~/.cargo/bin
