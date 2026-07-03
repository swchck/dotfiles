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

<!-- populated during the sweep -->

- **[H] yazi config parse error** — `yazi --version` fails with `TOML parse error at line 56`.
  yazi is at **26.5.6**; config written for an older schema (`[plugin] prepend_previewers`
  format changed). Config is effectively not loading. _(to fix)_
- **[H] settings.json template drift** — deployed `~/.claude/settings.json` has out-of-band
  additions not in the chezmoi source template (`tui`, `voice`, `voiceEnabled`,
  `skipWorkflowUsageWarning`, plugin `code-simplifier`, marketplace `01tech-plugins`,
  key reordering). A plain `chezmoi apply` would wipe them. Needs reconciliation into
  `src/dot_claude/settings.json.tmpl` + `.chezmoidata`. _(to fix)_
- **[M] brew outdated (7)** — gh, go-task, libtiff, llama.cpp, poppler, claude-code, octarine. _(to review/upgrade)_

### Deferred

<!-- populated during the sweep -->
