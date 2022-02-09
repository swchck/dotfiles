# Dotfiles

## Git Hooks

To extend your `git` hooks, create executable scripts in
`~/dotfiles-local/git_template.local/hooks/*` files.

## TMUX VARS

```bash
$(echo $USER) - shows the current username
%a --> Day of week (Mon)
%A --> Day of week Expanded (Monday
%b --> Month (Jan)
%d --> Day (31)
%Y --> Year (2017
%D --> Month/Day/Year (12/31/2017)
%v --> Day-Month-Year (31-Dec-2017
%r --> Hour:Min:Sec AM/PM (12:30:27 PM)
%T --> 24 Hour:Min:Sec (16:30:27)
%X --> Hour:Min:Sec (12:30:27)
%R --> 24 Hour:Min (16:30)
%H --> 24 Hour (16)
%l --> Hour (12)
%M --> Mins (30)
%S --> Seconds (09)
%p --> AM/PM (AM)
```

*For a more complete list view: https://linux.die.net/man/3/strftime*

```bash
colour0 (black)
colour1 (red)
colour2 (green)
colour3 (yellow)
colour4 (blue)
colour7 (white)
colour5 
colour6 
colour7 
colour8 
colour9 
colour10 
colour11 
colour12 
colour13 
colour14 
colour15 
colour16 
colour17
```

```bash
D ()
F ()
H (hostname)
I (window index)
P ()
S (session index)
T (pane title)
W (currnet task like vim if editing a file in vim or zsh if running zsh)
```

## ZSH Configurations

Additional zsh configuration can go under the `~/dotfiles-local/zsh/configs` directory. This
has two special subdirectories: `pre` for files that must be loaded first, and
`post` for files that must be loaded last.

For example, `~/dotfiles-local/zsh/configs/pre/virtualenv` makes use of various shell
features which may be affected by your settings, so load it first:

    # Load the virtualenv wrapper
    . /usr/local/bin/virtualenvwrapper.sh

Setting a key binding can happen in `~/dotfiles-local/zsh/configs/keys`:

    # Grep anywhere with ^G
    bindkey -s '^G' ' | grep '

Some changes, like `chpwd`, must happen in `~/dotfiles-local/zsh/configs/post/chpwd`:

    # Show the entries in a directory whenever you cd in
    function chpwd {
      ls
    }

This directory is handy for combining dotfiles from multiple teams; one team
can add the `virtualenv` file, another `keys`, and a third `chpwd`.

The `~/dotfiles-local/zshrc.local` is loaded after `~/dotfiles-local/zsh/configs`.

## What's in it?

[tmux](http://robots.thoughtbot.com/a-tmux-crash-course)
configuration:

* Improve color resolution.
* Remove administrative debris (session name, hostname, time) in status bar.
* Set prefix to `Ctrl+s`
* Soften status bar color from harsh green to light gray.

[git](http://git-scm.com/) configuration:

* Adds a `create-branch` alias to create feature branches.
* Adds a `delete-branch` alias to delete feature branches.
* Adds a `merge-branch` alias to merge feature branches into master.
* Adds an `up` alias to fetch and rebase `origin/master` into the feature
  branch. Use `git up -i` for interactive rebases.
* Adds `post-{checkout,commit,merge}` hooks to re-index your ctags.
* Adds `pre-commit` and `prepare-commit-msg` stubs that delegate to your local
  config.
* Adds `trust-bin` alias to append a project's `bin/` directory to `$PATH`.