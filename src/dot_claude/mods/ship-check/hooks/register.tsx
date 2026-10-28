import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register } from 'claude-code'

import type { ShipCheckKind, ShipCheckRepo, ShipCheckRuns } from '../types'

const PANE = 'ship-check'
const roots = atom({ plugin: 'ship-check', key: 'roots' } as const, [])
const repos = atom({ plugin: 'ship-check', key: 'repos' } as const, {})
const runs = atom({ plugin: 'ship-check', key: 'runs' } as const, {})

const KINDS: readonly ShipCheckKind[] = ['tests', 'lint', 'app', 'review']
const KIND_OF_COMMAND: ReadonlyArray<[ShipCheckKind, RegExp]> = [
  ['tests', /\b(?:go test|task test|pytest|make test|npm (?:run )?test)\b/],
  ['lint', /\b(?:golangci-lint|task lint|go vet|ruff|make lint)\b/],
  ['app', /\b(?:go run|task run|task up|docker compose up|make run)\b/],
]
const REVIEW_COMMANDS = new Set(['code-review', 'review', 'simplify', 'security-review', 'code-review:code-review'])
const TRACKED_GIT = /\bgit\b[^;&|]*\b(?:commit|checkout\s+-[bB]|switch\s+-[cC]|worktree\s+add|rebase|cherry-pick)\b/
const IGNORED_ROOT = /\/\.claude\//

const SHIP_PROMPT = (list: string[]) =>
  [
    'ship-check: доведи ветки задачи до мержа в этих репозиториях:',
    ...list.map(r => `- ${r}`),
    '',
    'Строго по порядку, в каждом репо:',
    '1. `git fetch`, ребейз ветки задачи на свежий origin/master; конфликты реши, миграции оставь последними по номеру.',
    '2. Upstream ветки — origin/<та же ветка>, никогда не origin/master.',
    '3. Тесты, линтер, сборка; подними приложение и убедись, что оно стартует и отвечает.',
    '4. Только после зелёных шагов 1–3: /code-review, /security-review, /simplify. Чини найденное и повторяй, пока ревью чистое.',
    '5. Комментарии в диффе — по ~/.claude/code-comments-rules.md.',
    'Не пушь. В конце: одна строка вердикта и нумерованный порядок релиза «репо → push/тег → команда».',
  ].join('\n')

const RELEASE_PROMPT = (list: string[]) =>
  [
    'ship-check: дай порядок релиза для репозиториев задачи:',
    ...list.map(r => `- ${r}`),
    'Нумерованный список «шаг: репо → push или тег → команда», каждая команда в своём блоке bash.',
    'Учитывай зависимости (либы тегаются раньше игр, миграции раньше кода). Без пояснений, кроме одной строки на опасный шаг.',
  ].join('\n')

function joinPath(base: string, path: string): string {
  if (path.startsWith('/') || path.startsWith('~/')) return path
  return `${base.replace(/\/$/, '')}/${path}`
}

function dirOf(path: string): string {
  return path.replace(/\/[^/]*$/, '') || '/'
}

function targetDir(command: string, cwd: string): string {
  const gitC = [...command.matchAll(/\bgit\s+-C\s+("[^"]+"|'[^']+'|\S+)/g)].pop()
  if (gitC) return joinPath(cwd, gitC[1]!.replace(/^["']|["']$/g, ''))
  const cd = [...command.matchAll(/(?:^|&&|;)\s*cd\s+("[^"]+"|'[^']+'|[^\s;&]+)/g)].pop()
  if (cd) return joinPath(cwd, cd[1]!.replace(/^["']|["']$/g, ''))
  return cwd
}

async function git($: EngineInterface, dir: string, args: string[], timeoutMs = 8000): Promise<string | null> {
  try {
    const r = await $.process.run(['git', '-C', dir, ...args], { timeoutMs })
    return r.exitCode === 0 ? r.stdout.trim() : null
  } catch {
    return null
  }
}

const rootCache = new Map<string, string | null>()
// a review command only loads its instructions, the review runs in the turn after; heads are
// snapshotted at that point so fixes made during the review leave the mark stale, not green
let reviewHeads: Record<string, string> | null = null

async function rootOf($: EngineInterface, dir: string): Promise<string | null> {
  if (rootCache.has(dir)) return rootCache.get(dir) ?? null
  const root = await git($, dir, ['rev-parse', '--show-toplevel'])
  const kept = root !== null && !IGNORED_ROOT.test(root) ? root : null
  rootCache.set(dir, kept)
  return kept
}

async function track($: EngineInterface, dir: string): Promise<string | null> {
  const root = await rootOf($, dir)
  if (root === null) return null
  const known = await read($, roots)
  if (!known.includes(root)) {
    await update($, roots, list => (list.includes(root) ? list : [...list, root]))
    await refresh($, root)
  }
  return root
}

async function exists($: EngineInterface, path: string): Promise<boolean> {
  try {
    await $.fs.stat(path)
    return true
  } catch {
    return false
  }
}

async function refresh($: EngineInterface, root: string) {
  const status = await git($, root, ['status', '--porcelain=v2', '--branch'])
  if (status === null) return
  const lines = status.split('\n')
  const header = (key: string) => lines.find(l => l.startsWith(`# branch.${key} `))?.slice(`# branch.${key} `.length) ?? null

  const base = (await git($, root, ['rev-parse', '--abbrev-ref', 'origin/HEAD'])) ?? 'origin/master'
  const counts = (await git($, root, ['rev-list', '--left-right', '--count', `${base}...HEAD`])) ?? '0\t0'
  const [behind = 0, ahead = 0] = counts.split(/\s+/).map(Number)
  const rebaseMerge = await git($, root, ['rev-parse', '--git-path', 'rebase-merge'])
  const rebaseApply = await git($, root, ['rev-parse', '--git-path', 'rebase-apply'])
  const isRebasing =
    (rebaseMerge !== null && (await exists($, joinPath(root, rebaseMerge)))) ||
    (rebaseApply !== null && (await exists($, joinPath(root, rebaseApply))))

  const repo: ShipCheckRepo = {
    root,
    name: root.split('/').pop() ?? root,
    branch: header('head') ?? '?',
    upstream: header('upstream'),
    base,
    behind,
    ahead,
    dirty: lines.filter(l => /^[12?] /.test(l)).length,
    conflicts: lines.filter(l => l.startsWith('u ')).length,
    isRebasing,
    head: header('oid') ?? '',
  }
  await update($, repos, all => ({ ...all, [root]: repo }))
}

async function refreshAll($: EngineInterface, isFetch = false) {
  for (const root of await read($, roots)) {
    if (isFetch) await git($, root, ['fetch', '--quiet', 'origin'], 60_000)
    await refresh($, root)
  }
}

async function record($: EngineInterface, root: string, kind: ShipCheckKind, isOk: boolean, at?: string) {
  await refresh($, root)
  const head = at ?? (await read($, repos))[root]?.head ?? ''
  await update($, runs, all => ({ ...all, [root]: { ...all[root], [kind]: { isOk, head } } }))
}

async function snapshotHeads($: EngineInterface): Promise<Record<string, string>> {
  await refreshAll($)
  const all = await read($, repos)
  return Object.fromEntries(Object.entries(all).map(([root, repo]) => [root, repo.head]))
}

function problemsOf(repo: ShipCheckRepo, done: ShipCheckRuns): string[] {
  const out: string[] = []
  const isDefault = /^(?:master|main)$/.test(repo.branch)
  if (isDefault) out.push('работа прямо в master')
  if (repo.upstream === null) out.push('нет upstream')
  else if (!isDefault && /\/(?:master|main)$/.test(repo.upstream)) out.push(`upstream → ${repo.upstream}`)
  if (repo.behind > 0) out.push(`отстаёт от ${repo.base} на ${repo.behind}`)
  if (repo.isRebasing) out.push('ребейз не закончен')
  if (repo.conflicts > 0) out.push(`конфликты: ${repo.conflicts}`)
  if (repo.dirty > 0) out.push(`незакоммичено: ${repo.dirty}`)
  for (const kind of KINDS) {
    const run = done[kind]
    if (run === undefined) out.push(`${kind}: не запускали`)
    else if (!run.isOk) out.push(`${kind}: упало`)
    else if (run.head !== repo.head) out.push(`${kind}: устарело`)
  }
  return out
}

async function openPane($: EngineInterface) {
  await refreshAll($)
  return $.ui.open({ id: PANE, title: 'Ship check' })
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({
      name: 'ship-check',
      description: 'Pre-merge status of the task repos; `run` drives them to merge, `release` asks for the release order, `add <path>` tracks a repo',
    })
    return next(e)
  })

  on('command.run', async ($, e, next) => {
    if (REVIEW_COMMANDS.has(e.command)) {
      reviewHeads = await snapshotHeads($)
      return next(e)
    }
    if (e.command !== 'ship-check') return next(e)

    const [verb = '', ...rest] = e.args.trim().split(/\s+/).filter(Boolean)
    const cwd = await $.session.cwd()
    if (verb === 'add') {
      const added: string[] = []
      for (const p of rest.length ? rest : [cwd]) {
        const root = await track($, joinPath(cwd, p))
        if (root) added.push(root)
      }
      await openPane($)
      return { text: added.length ? `ship-check: слежу за ${added.join(', ')}` : 'ship-check: это не git-репозиторий' }
    }
    if (verb === 'clear') {
      await update($, roots, () => [])
      await update($, repos, () => ({}))
      await update($, runs, () => ({}))
      return { text: 'ship-check: список репозиториев очищен' }
    }
    const list = await read($, roots)
    if (verb === 'run' || verb === 'release') {
      if (list.length === 0) return { text: 'ship-check: пока нет репозиториев задачи, добавь `/ship-check add <path>`' }
      await openPane($)
      void $.prompt.submit({ text: verb === 'run' ? SHIP_PROMPT(list) : RELEASE_PROMPT(list) })
      return { text: `ship-check: ${verb === 'run' ? 'довожу до мержа' : 'собираю порядок релиза'} (${list.length} репо)` }
    }
    await openPane($)
    return { text: `ship-check: ${list.length} репо в панели` }
  })

  on('tool.call', async ($, e, next) => {
    if (e.tool === 'Skill') {
      const ran = await next(e)
      const name = String((e as { skill?: unknown }).skill ?? '')
      if (REVIEW_COMMANDS.has(name) && ran.isError !== true && ran.deny === undefined) reviewHeads = await snapshotHeads($)
      return ran
    }
    if (e.tool === 'Edit' || e.tool === 'Write') {
      const ran = await next(e)
      if (ran.deny === undefined && ran.isError !== true) await track($, dirOf(e.file_path))
      return ran
    }
    if (e.tool !== 'Bash') return next(e)

    const kind = KIND_OF_COMMAND.find(([, re]) => re.test(e.command))?.[0]
    const isGit = TRACKED_GIT.test(e.command)
    const ran = await next(e)
    if (kind === undefined && !isGit) return ran
    if (ran.deny !== undefined) return ran

    const dir = targetDir(e.command, await $.session.cwd())
    const root = isGit ? await track($, dir) : await rootOf($, dir)
    if (root === null || !(await read($, roots)).includes(root)) return ran
    if (kind !== undefined) await record($, root, kind, ran.isError !== true)
    else await refresh($, root)
    return ran
  })

  on('turn.complete', async ($, e, next) => {
    if (reviewHeads !== null) {
      const heads = reviewHeads
      reviewHeads = null
      for (const root of await read($, roots)) await record($, root, 'review', true, heads[root] ?? '')
    }
    void refreshAll($)
    return next(e)
  })

  on('ui.render', { component: 'Pane', requestId: PANE }, async ($, e) => {
    const { Box, Text, Button } = $.ui.resolve(e)
    const list = await read($, roots)
    const all = await read($, repos)
    const done = await read($, runs)

    const rows = list.map(root => {
      const repo = all[root]
      return { root, repo, problems: repo ? problemsOf(repo, done[root] ?? {}) : ['нет данных'] }
    })
    const total = rows.reduce((n, r) => n + r.problems.length, 0)
    const mark = (kind: ShipCheckKind, repo: ShipCheckRepo | undefined, own: ShipCheckRuns) => {
      const run = own[kind]
      if (run === undefined) return { text: `${kind} ·`, color: undefined, dim: true }
      if (!run.isOk) return { text: `${kind} ✗`, color: 'red', dim: false }
      if (repo && run.head !== repo.head) return { text: `${kind} ~`, color: 'yellow', dim: false }
      return { text: `${kind} ✓`, color: 'green', dim: false }
    }

    return (
      <Box flexDirection="column">
        {list.length === 0 ? (
          <Text dimColor>Репозитории появятся, когда начнутся правки, или через /ship-check add &lt;path&gt;</Text>
        ) : (
          <Text bold color={total === 0 ? 'green' : 'yellow'}>
            {total === 0 ? 'Готово к мержу' : `Не готово: ${total}`}
          </Text>
        )}
        {rows.map(({ root, repo, problems }) => (
          <Box key={root} flexDirection="column" marginTop={1}>
            <Text bold wrap="truncate">
              {repo?.name ?? root}{' '}
              <Text dimColor>
                {repo ? `${repo.branch} → ${repo.upstream ?? '—'}  ↓${repo.behind} ↑${repo.ahead}` : ''}
              </Text>
            </Text>
            <Text>
              {KINDS.map(kind => {
                const m = mark(kind, repo, done[root] ?? {})
                return (
                  <Text key={kind} color={m.color} dimColor={m.dim}>
                    {m.text}
                    {'  '}
                  </Text>
                )
              })}
            </Text>
            {problems
              .filter(p => !KINDS.some(k => p.startsWith(`${k}:`)))
              .map(p => (
                <Text key={p} color="yellow" wrap="truncate">
                  {'  '}! {p}
                </Text>
              ))}
          </Box>
        ))}
        <Box marginTop={1} flexWrap="wrap">
          <Button key="refresh" label="Обновить" hotkey="r" onPress={() => refreshAll($)} />
          <Button key="fetch" label="git fetch" hotkey="f" onPress={() => refreshAll($, true)} />
          <Button
            key="run"
            label="Довести до мержа"
            hotkey="s"
            variant="primary"
            onPress={async () => {
              const l = await read($, roots)
              if (l.length) await $.prompt.submit({ text: SHIP_PROMPT(l) })
            }}
          />
          <Button
            key="release"
            label="Порядок релиза"
            hotkey="p"
            onPress={async () => {
              const l = await read($, roots)
              if (l.length) await $.prompt.submit({ text: RELEASE_PROMPT(l) })
            }}
          />
        </Box>
      </Box>
    )
  })
}
