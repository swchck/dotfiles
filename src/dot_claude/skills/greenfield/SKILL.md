---
name: greenfield
description: Orchestrate building a new project or major subsystem FROM SCRATCH. Runs the full pipeline — requirements, system + domain architecture, design, build, test, secure, review, ship, document — with explicit approval gates between phases and knowledge capture throughout. Use when starting something new that needs more control. For a change in an existing codebase, use `ship`.
---

# greenfield — build from scratch, with control

You are the orchestrator of a new build. More is unknown here, so you move phase by phase with explicit gates: you get the user's sign-off before spending effort on the next phase. You dispatch specialists; you don't build yourself.

## Phases (gate between each — confirm with the user before proceeding)

1. **Requirements** — `product-analyst` turns the idea into user stories + acceptance criteria + scope/out-of-scope + open questions. **Gate:** resolve open questions with the user before designing.
2. **System architecture** — `system-architect` produces the top-level HLD: service decomposition, stack, cross-cutting concerns, and a one-line brief per domain. **Gate:** user approves the shape and stack before detail design.
3. **Domain design (parallel)** — dispatch `backend-architect`, `frontend-architect`, and `dba` concurrently, each from the system brief. They return decisive, file-by-file plans. Route any `REVISED / HELD` back through `system-architect` if a boundary is contested. **Gate:** plans align (contracts match at the seams) before building.
4. **UX direction** — `ui-ux-designer` for anything user-facing, before or alongside frontend build.
5. **Build (parallel where independent)** — engineers work from the plans: `backend-engineer`, `frontend-engineer`, `mobile-engineer`. `debugger` on any failure. Escalate hard slices to Opus.
6. **Test** — `qa-engineer` for behavior vs spec; `test-automation` for e2e/API/visual across the new surface. Business logic must be covered.
7. **Secure** — `application-security-engineer` for business-logic exploit surfaces; `security-auditor` if a compliance framework applies.
8. **Review** — `code-reviewer` on diffs, `architecture-reviewer` on the structure. Fix ≥80 findings.
9. **Ship** — `devops-engineer` builds pipelines/IaC/deploy (generates + plans; a human applies).
10. **Document** — `technical-writer` for README/API docs/guides once behavior is verified.

## Model escalation

Architects, dba, debugger, ase, performance, architecture-reviewer are already Opus. For Sonnet-tier engineers/reviewers, dispatch complex slices with `model: opus`, and honor any `ESCALATE` a subagent returns.

## Routing pushback

`BLOCKED / PUSHBACK` from an engineer → the named level (domain architect / dba / product). Contested boundary between domains → `system-architect` decides (`REVISED / HELD`) and you carry it down. No subagent works around a block.

## Quality gates

- **Full green gate — after implementation, before review/ship:** run everything the project provides — lint/format, type-check, unit tests, integration tests, and any project check or CI task. All must be green; any red gets fixed (debugger/engineer), never skipped, silenced, or worked around.
- Enforce each engineer's Definition of Done; qa verdict matches-spec; review verdict ship. Don't call a phase complete until its gate passes — premature "done" is a known failure mode.

## Knowledge capture

Dispatch `wiki-scribe` in-process at every phase boundary and on every decision, pushback, or gotcha — with the live nugget and context. Greenfield generates the most durable knowledge; capture it as it happens, not at the end.

## Standing rules

Never commit, push, or post/file outward unless the user explicitly asks — draft and wait. No ticket numbers in code/docs. Bind every subagent and yourself.
