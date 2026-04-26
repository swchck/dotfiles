---
description: Orchestrate explorer → architect → engineer → qa → (aqa) → reviewer pipeline for a feature or fix
argument-hint: feature description or bug to fix
---

# Ship

You are orchestrating an end-to-end implementation pipeline. Run the agents serially in the order below. Pass each agent ONLY what they need — never the full conversation.

Task: $ARGUMENTS

## Stage 0 — Triage (do this in your own context, no agent)

Classify the task. Tell the user your classification before delegating, so they can interrupt.

| Class | Pipeline |
|---|---|
| **trivial** (one-line fix, rename, typo) | engineer only, then stop |
| **bugfix** (localized behavior change) | engineer → qa → reviewer |
| **feature-lib** (new code, no UI/HTTP surface) | explorer → architect → engineer → qa → reviewer |
| **feature-ui** (touches UI or HTTP API) | explorer → architect → engineer → qa → aqa → reviewer |

If you can't tell, ask the user one specific question and wait. Don't guess.

## Stage 1 — explorer (skip for trivial / bugfix on a known file)

Delegate to `explorer`. Pass: the task description and any area hints the user gave.

After explorer returns:
- Read the files explorer marked essential. Do not pass file contents to subsequent agents — pass file paths + the explorer's report.

## Stage 2 — architect (skip for trivial / simple bugfix)

Delegate to `architect`. Pass: task + explorer's report (verbatim, it's already terse).

Output: a blueprint. If architect says "trivial — engineer can proceed directly", skip to engineer with just the touch points.

## Stage 3 — engineer

Delegate to `engineer`. Pass: blueprint (or task description if no blueprint).

Engineer must run the unit tests they wrote and confirm green before returning. If they return without green tests, send back with "tests must pass" and stop after one retry.

## Stage 4 — qa

Delegate to `qa`. Pass: original task spec + summary of what engineer changed (file:line list).

If qa returns `matches-spec` → continue.
If qa returns `partial` or `diverges` → send the gaps back to engineer ONCE. If still gaps, surface to user — don't loop a third time.

## Stage 5 — aqa (only for feature-ui)

Delegate to `aqa`. Pass: the user-facing flows that need coverage + entry-point file:line.

aqa writes Playwright specs and runs them. If green, continue. If red, surface the failure — don't auto-fix.

## Stage 6 — reviewer

Delegate to `reviewer` last. Pass: file:line list of changes (or `git diff` instruction).

Reviewer reports only findings ≥ 80 confidence. If `ship` → done. If `fix-first` → surface to user.

## Final report (you, in main thread)

≤ 8 lines:
- Class chosen + which stages ran
- What was built (1 line)
- Tests added (count + green/red)
- Spec verification result
- e2e result if aqa ran
- Reviewer verdict
- Files touched (paths only, no diff)
- Open questions for the user (if any)

## Token discipline

- Never paste full file contents into subagent prompts — pass file:line references.
- Never re-run a stage you already ran unless the user asks.
- Skip stages liberally based on triage. Default to LESS pipeline, not more.
- If two stages would duplicate work (e.g., explorer + architect both scanning the same area), collapse them.
