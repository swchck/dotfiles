# Config Review Log

Tracks periodic full sweeps of the dotfiles: when configs were last reviewed
against current tool versions, what changed, and what was adopted or deferred.

- **Machine-readable version snapshot:** [`versions.lock`](./versions.lock) (regenerated each review).
- **Not deployed:** these files live in the repo root (outside `src/`), so chezmoi never applies them.
- **Next audit:** `diff versions.lock <(fresh snapshot)` to see version drift, then re-run the per-tool sweep.

| Review date | chezmoi | Claude Code | Scope | Outcome |
|---|---|---|---|---|
| 2026-07-04 | v2.70.5 | 2.1.187 | First full sweep — all 27 configured tools | _in progress_ |

---

## 2026-07-04 — First full sweep

**Baseline:** repo created 2026-03-29 (69 commits). No prior review checkpoint —
this establishes the baseline. Most configs date to 2026-03-29; `fish`, `git`,
`github-copilot` to 2026-05-17; `nvim`, `starship` to 2026-05-18; `wezterm` to 2026-07-04.

**Method:** per-tool comparison of installed version vs config-authoring date,
cross-checked against current upstream docs; findings prioritized H/M/L and applied
in grouped commits.

### Findings

Severity: **H** = broken / deprecated / user-visible; **M** = worth adopting; **L** = nice-to-have.
Reviewed via 6 parallel per-tool doc-checked passes. `[x]` = fixed this sweep.

#### H — broken or dead right now
- [ ] **yazi** — whole config fails to parse (`yazi.toml:56`). `[manager]`→`[mgr]` rename (v25.5.28) in `yazi.toml` **and** `keymap.toml`; `prepend_previewers` key `name`→`url`. Fixing restores yazi entirely.
- [ ] **nvim / treesitter** — `treesitter.lua` sets `main = "nvim-treesitter.config"` but passes the old `master`-schema opts (`ensure_installed`/`highlight`/`indent`/`auto_install`) → all silently ignored: **no TS highlight/indent, parsers not installed**. Fix = pin `branch="master"`+`configs.setup` OR migrate to new imperative API. (judgment call — 2 approaches)
- [ ] **nvim** — `vim.highlight.on_yank()` deprecated → `vim.hl.on_yank()` (`autocommands.lua:11`).
- [ ] **fish** — duplicate/conflicting handlers: `bind space _expand_bang_bang` vs `last_command.fish` (both do `!!`); inline `bind ctrl-z` vs unused `ctrl_z_toggle.fish`. Dead code + `bind space` footgun. (judgment: pick one each)
- [ ] **fish** — `functions/.../path.fish` shadows the built-in `path` command → rename (e.g. `showpath`).
- [ ] **starship** — `[kubernetes]` `context_aliases`/`user_aliases` map form removed → migrate to `[[kubernetes.contexts]]`.
- [ ] **k9s** — `skin` nested under `ui:` (must be top-level `k9s:`) → skin silently not applied; `enableSkinsFromDir` is not a real key → remove.
- [ ] **fd** — `ignore.tmpl:17` negation `.../!/Library/CloudStorage/` is dead (gitignore can't re-include under excluded parent).
- [ ] **openfortivpn** — `primary.conf.tmpl:21` typo `use-resolveconf`→`use-resolvconf` (inert on macOS anyway; silently ignored).
- [ ] **act** — `actrc` maps retired `ubuntu-20.04` image; no `ubuntu-24.04` mapping (now `ubuntu-latest`).
- [ ] **lazygit** — legacy `git.paging` (auto-migrated) → move to `git.pagers: []` array.
- [ ] **zed** — `agent.default_model.provider: "claude-acp"` reportedly invalid (ACP agents belong in `agent_servers`, not `default_model`). (needs verification — active AI setup)
- [ ] **bottom** — commented `[flags]` block uses removed flat schema (latent; only bites if uncommented).
- [x] **settings.json (Claude Code)** — deployed drift vs chezmoi source (`tui`,`voice`,`voiceEnabled`,`skipWorkflowUsageWarning`, plugin `code-simplifier`, marketplace `01tech-plugins`). Hooks added directly to deployed file this session; source reconciliation deferred — **contains work data (`01tech-plugins` → gitlab.rip)**, must be gated behind work profile / kept out of the public repo. (needs decision)

#### M — worth adopting
- [ ] **bat** — `--theme=auto` + `--theme-light`/`--theme-dark` for light/dark switching (already scaffolded, commented).
- [ ] **ripgrep** — `--hyperlink-format=default` → clickable paths in WezTerm/Ghostty.
- [ ] **gh** — add `telemetry: disabled` (default is enabled; matches privacy pattern elsewhere).
- [ ] **ghorg** — `GHORG_TOKEN_CMD` instead of embedding decrypted token in rendered YAML.
- [ ] **zsh** — `chsh`+`sudo tee /etc/shells` runs on every zsh startup (sudo-prompt footgun) → move to `run_once_`; guard `fzf/atuin/zoxide/starship` evals with `command -v` like `dot_bashrc` does.
- [ ] **zoxide** — replace hand-written `cd.fish` with `zoxide init fish --cmd cd` (custom fn has dead branch, no `cd -`).
- [ ] **fzf** — `--style` presets, `--highlight-line`, `--gap`, optional `--tmux/--popup` (v0.58+).
- [ ] **nvim** — Mason called `setup()` twice; canonical repos now `mason-org/*`; consider blink.cmp over nvim-cmp.
- [ ] **brew outdated (7)** — gh, go-task, libtiff, llama.cpp, poppler, claude-code, octarine.
- [ ] **packages undeclared** — installed but not in `packages*.toml`: `glab`, `hashicorp/tap/vault`, `node@22`, casks `github-copilot-app`, `octarine`, `pomo`.

#### L — nice-to-have / cosmetic
- [ ] Stale version-header comments: zellij (0.43.1→0.44.3), delta (0.18.2→0.19.2), lazygit (0.60.0→0.62.2), bottom (0.12.3→0.14.3), starship (1.24.2→1.26.0), atuin (18.13.2→18.16.1), yazi (26.1.22→26.5.6), procs (0.14.11→0.14.12), fish (Fish 4.5.0→4.8.0).
- [ ] yazi comments reference removed `ya pack` → now `ya pkg`.
- [ ] ssh — add `IdentitiesOnly yes` under `Host *`.
- [ ] git — `protocol.version=2` redundant (default since 2.26); consider `git maintenance`/commit-graph.
- [ ] fish — `sed`→`sd` alias breaks `s/…/…/` muscle-memory.
- **Clean (no findings):** topgrade, yt-dlp, atuin, eza, gram, github-copilot, code-stats, wezterm (installed = latest stable; new features only on nightly).

### Deferred (need your decision — see session summary)
- nvim treesitter migration approach; fish `!!`/Ctrl+Z dedup; zed `claude-acp`; settings.json work-data reconciliation; brew upgrades; behavior-changing adoptions (bat theme, zoxide cd, fzf style).
