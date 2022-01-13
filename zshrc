# load custom executable functions
for function in ~/.zsh/functions/*; do
  source $function
done

# extra files in ~/.zsh/configs/pre , ~/.zsh/configs , and ~/.zsh/configs/post
# these are loaded first, second, and third, respectively.
_load_settings() {
  _dir="$1"
  if [ -d "$_dir" ]; then
    if [ -d "$_dir/pre" ]; then
      for config in "$_dir"/pre/**/*~*.zwc(N-.); do
        . $config
      done
    fi

    for config in "$_dir"/**/*(N-.); do
      case "$config" in
        "$_dir"/(pre|post)/*|*.zwc)
          :
          ;;
        *)
          . $config
          ;;
      esac
    done

    if [ -d "$_dir/post" ]; then
      for config in "$_dir"/post/**/*~*.zwc(N-.); do
        . $config
      done
    fi
  fi
}
_load_settings "$HOME/.zsh/configs"

# Local config
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# aliases
[[ -f ~/.aliases ]] && source ~/.aliases

# if [[ ! -d ~/.zplug ]]; then
#   git clone https://github.com/zplug/zplug ~/.zplug
# fi

# source ~/.zplug/init.zsh

# # List of Zplug plugins
# zplug "plugins/git", from:oh-my-zsh
# zplug "plugins/command-not-found", from:oh-my-zsh
# zplug "zsh-users/zsh-syntax-highlighting"
# zplug "zsh-users/zsh-history-substring-search"
# zplug "zsh-users/zsh-completions"
# zplug "themes/robbyrussell", from:oh-my-zsh, as:theme
# zplug "romkatv/powerlevel10k", as:theme, depth:1

# if ! zplug check; then
# printf "Install? [y/N]: "
# if read -q; then
# echo; zplug install
# fi
# fi
# zplug load

# # Would you like to use another custom folder than $ZSH/custom?
# # ZSH_CUSTOM=/path/to/new-custom-folder

# source $ZSH/oh-my-zsh.sh
# eval $(thefuck --alias)

# # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
