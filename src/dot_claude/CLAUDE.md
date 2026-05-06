@RTK.md

## Git commits

- NEVER mention AI authorship or AI-assisted generation in commit messages, PR descriptions, or code comments (product names like `claude-dashboard` are fine — only authorship/generation phrases are banned). Auto-trailer is already disabled via `attribution.commit = ""`.
- NEVER mention any information connected to work context, such as project names, company names, or any other identifiable information in commit messages, PR descriptions, or code comments to personal repositories, as they may be public and visible to others

## Working Style

- Fix root causes, not symptoms. Avoid temporary stubs, manual SQL seeding, or workarounds when the underlying code can be corrected. If a workaround is truly needed, call it out explicitly and ask before proceeding.
- When the user pushes back on a hypothesis or says something is not the case (e.g., 'manual-only sync is configured', 'I can't collect pprof'), drop that hypothesis entirely and re-investigate — do not keep circling the rejected theory.

## Multi-Step Tasks

Do not declare a multi-phase task complete until ALL phases pass build + tests + lint. When executing migration plans, finish the current phase fully (including verification) before moving on, and never claim 'done' prematurely.

## Communication

Respond in Russian when the user writes in Russian. Match the user's language throughout the session.

## Wiki Knowledge Base

Path: `~/.repository/personal/llm-memory`

Cross-project persistent wiki maintained via the `claude-obsidian` plugin (Karpathy's LLM Wiki pattern). Use it to file lessons, errors, decisions, and reusable insights across all projects.

When you need context not already in the current project:

1. Read `wiki/hot.md` first (recent context, ~500 words).
2. If not enough, read `wiki/index.md`.
3. If you need domain specifics, read `wiki/<domain>/_index.md`.
4. Only then read individual wiki pages.

Do NOT read the wiki for general coding questions or things already documented in the current project.

To file something into the wiki use `/save` (current conversation) or `ingest <source>` (external file). For wiki health run `lint the wiki` periodically.

Primary source for lessons and recurring frictions: `~/.claude/usage-data/` — Claude Code writes per-session post-mortems there (`facets/<id>.json` with `underlying_goal`, `outcome`, `friction_detail`; `session-meta/<id>.json` with `project_path`, `tool_counts`, `first_prompt`). Ingest these to seed and refresh the wiki.
