# Dotfiles

Chezmoi-managed dotfiles for macOS (personal & work) and containers.

## Quick Start

### macOS (full setup)

Bootstrap script installs Xcode CLI tools, Homebrew, and applies all dotfiles:

```bash
bash <(curl -s https://raw.githubusercontent.com/swchck/dotfiles/master/setup.sh)
```

### Manual installation

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply swchck
```

### Container / Codespace / SSH server

One-liner — installs only shell configs, no GUI apps or install scripts:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply swchck
```

Automatically detected via `CODESPACES`, `REMOTE_CONTAINERS` env vars, `/.dockerenv`, or username (`root`, `ubuntu`, `vscode`).

### Dev Container

Included `.devcontainer/devcontainer.json` runs `chezmoi init --apply` on creation.

## What gets installed

### macOS (interactive)

| Category         | What                                                             |
| ---------------- | ---------------------------------------------------------------- |
| Shell            | Fish + Starship prompt + Atuin history + Zoxide + fzf            |
| Editors          | Neovim (kickstart + lazy.nvim), Zed, Gram                        |
| Terminals        | WezTerm (tabline + resurrect plugins), Ghostty, Zellij           |
| CLI replacements | bat, eza, fd, ripgrep, sd, dust, bottom, procs, viddy, bandwhich |
| Git              | delta, lazygit, gitsigns, deadbranch, ghorg                      |
| DevOps           | k9s, Docker (OrbStack), OpenFortiVPN (work)                      |
| Packages         | Homebrew formulae, casks, App Store apps, VS Code extensions     |
| Theme            | Catppuccin Mocha everywhere                                      |

### Container / Codespace (headless)

Fish + Starship + fzf + Atuin + Zoxide + bat + eza + fd + ripgrep + Neovim + Git config. No GUI apps, no install scripts, no encrypted files.

## Machine profiles

Prompted on first `chezmoi init`:

| Profile      | Includes                                                              |
| ------------ | --------------------------------------------------------------------- |
| **personal** | GitHub token, personal packages, ollama models, Flipper Zero, gaming  |
| **work**     | GitLab config, FortiVPN, k9s, protobuf/gRPC stack, Kafka, Slack, Zoom |

Both profiles share: core CLI tools, editors, terminals, shell config.

## Secrets

| Method             | Used for                                                                    |
| ------------------ | --------------------------------------------------------------------------- |
| **age encryption** | SSH private keys (stored encrypted in repo)                                 |
| **macOS Keychain** | GitLab token, GitHub token, VPN password, Code::Stats token, age secret key |

On a new machine:

```bash
# 1. Add age key to Keychain (needed for SSH key decryption)
security add-generic-password -a chezmoi -s age-secret-key -w '<AGE_SECRET_KEY>'

# 2. Add other secrets as needed
security add-generic-password -a chezmoi -s gitlab-token -w '<TOKEN>'
security add-generic-password -a chezmoi -s ghorg-github-token -w '<TOKEN>'
security add-generic-password -a chezmoi -s vpn-primary-password -w '<PASSWORD>'
security add-generic-password -a chezmoi -s code-stats-token -w '<TOKEN>'

# 3. Init and apply
chezmoi init --apply swchck
```

## Daily usage

```bash
chezmoi apply          # apply changes
chezmoi diff           # preview changes
chezmoi edit <file>    # edit managed file in nvim
chezmoi add <file>     # add new file
chezmoi update         # pull + apply
```
