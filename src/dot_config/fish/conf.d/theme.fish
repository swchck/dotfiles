# Fish 4.5.0 shell color theme — One Dark Pro
#
# To preview: fish_config theme show
# To reset to default: fish_config theme choose "Fish Default"

# Syntax highlighting
set -g fish_color_normal abb2bf           # fg
set -g fish_color_command 61afef          # blue
set -g fish_color_keyword c678dd          # purple
set -g fish_color_quote 98c379            # green
set -g fish_color_redirection 56b6c2      # cyan
set -g fish_color_end 98c379              # green
set -g fish_color_error e06c75            # red
set -g fish_color_param d19a66            # orange
set -g fish_color_comment 5c6370          # comment grey
set -g fish_color_selection --background=3e4452
set -g fish_color_search_match --background=3e4452
set -g fish_color_operator 56b6c2         # cyan
set -g fish_color_escape e06c75           # red
set -g fish_color_autosuggestion 636d83   # gutter grey
set -g fish_color_cancel e06c75           # red

# Completion pager
set -g fish_pager_color_progress 636d83   # gutter grey
set -g fish_pager_color_prefix c678dd     # purple
set -g fish_pager_color_completion abb2bf  # fg
set -g fish_pager_color_description 636d83 # gutter grey
set -g fish_pager_color_selected_background --background=3e4452

# Prompt elements
set -g fish_color_cwd e5c07b             # yellow
set -g fish_color_cwd_root e06c75        # red
set -g fish_color_user 56b6c2            # cyan
set -g fish_color_host 61afef            # blue
set -g fish_color_host_remote 98c379     # green
set -g fish_color_status e06c75          # red
set -g fish_color_valid_path --underline
set -g fish_color_history_current --bold
