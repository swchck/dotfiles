# Personal Setup Configuration

## Initialization via One-Shot Chezmoi Script

Using the following command you can download and run the one-shot script to initialize the chezmoi configuration.

### Install via `curl`

```shell
bash <(curl -s https://raw.githubusercontent.com/swchck/dotfiles/master/setup.sh)
```

### Install via `wget`

```shell
bash <(wget -qO- https://raw.githubusercontent.com/swchck/dotfiles/master/setup.sh)
```

## Manual Installation

1. Install `chezmoi` via `sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME"` or via wget `sh -c "$(wget -qO- get.chezmoi.io)" -- init --apply $GITHUB_USERNAME"`
