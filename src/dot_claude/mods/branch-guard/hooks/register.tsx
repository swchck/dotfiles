import type { EngineInterface, Register } from 'claude-code'

// personal repos (dotfiles and friends) push straight to master on purpose
const WORK_TREE_FALLBACK = /\/\.repository\/work\//
const DEFAULT_BRANCH = /^(?:origin\/)?(?:master|main)$/

const PUSH_TO_DEFAULT = /\bgit\b[^;&|]*\bpush\b[^;&|]*\s(?:HEAD:|\S+:)?(?:refs\/heads\/)?(?:master|main)(?=[\s;&|]|$)/
const UPSTREAM_TO_DEFAULT = /\bgit\b[^;&|]*\b(?:branch\b[^;&|]*(?:-u|--set-upstream-to)[ =]|push\b[^;&|]*(?:-u|--set-upstream)\s+\S+\s+\S+:)origin\/(?:master|main)\b/
const BRANCH_FROM_REMOTE_DEFAULT =
  /\bgit\b[^;&|]*\b(?:checkout\s+-[bB]|switch\s+-[cC]|worktree\s+add\b[^;&|]*-[bB])\s+\S+(?:\s+\S+)?\s+origin\/(?:master|main)\b/

function joinPath(base: string, path: string): string {
  if (path.startsWith('/')) return path
  if (path.startsWith('~/')) return path
  return `${base.replace(/\/$/, '')}/${path}`
}

function targetDir(command: string, cwd: string): string {
  const gitC = [...command.matchAll(/\bgit\s+-C\s+("[^"]+"|'[^']+'|\S+)/g)].pop()
  if (gitC) return joinPath(cwd, gitC[1]!.replace(/^["']|["']$/g, ''))
  const cd = [...command.matchAll(/(?:^|&&|;)\s*cd\s+("[^"]+"|'[^']+'|[^\s;&]+)/g)].pop()
  if (cd) return joinPath(cwd, cd[1]!.replace(/^["']|["']$/g, ''))
  return cwd
}

async function git($: EngineInterface, dir: string, args: string[]): Promise<string | null> {
  try {
    const r = await $.process.run(['git', '-C', dir, ...args], { timeoutMs: 5000 })
    return r.exitCode === 0 ? r.stdout.trim() : null
  } catch {
    return null
  }
}

async function tracking($: EngineInterface, dir: string) {
  const branch = await git($, dir, ['rev-parse', '--abbrev-ref', 'HEAD'])
  if (branch === null) return null
  const upstream = await git($, dir, ['rev-parse', '--abbrev-ref', '--symbolic-full-name', '@{u}'])
  return { branch, upstream }
}

async function refreshStatus($: EngineInterface, dir: string) {
  const t = await tracking($, dir)
  if (t === null) {
    $.ui.status(undefined)
    return null
  }
  const isWrong = t.upstream !== null && !DEFAULT_BRANCH.test(t.branch) && DEFAULT_BRANCH.test(t.upstream)
  $.ui.status(`${isWrong ? '⚠ ' : ''}${t.branch} → ${t.upstream ?? 'no upstream'}`)
  return { ...t, isWrong }
}

export const register: Register = (on, options) => {
  // the real path comes from pluginConfigs in settings.json, filled from chezmoi's paths.work
  const workTree = options.workTreePattern ? new RegExp(String(options.workTreePattern)) : WORK_TREE_FALLBACK

  on('session.start', async ($, e, next) => {
    void refreshStatus($, await $.session.cwd())
    return next(e)
  })

  on('tool.call', { tool: 'Bash' }, async ($, e, next) => {
    if (e.tool !== 'Bash') return next(e)
    const cwd = await $.session.cwd()
    const dir = targetDir(e.command, cwd)
    const isWork = workTree.test(dir) || workTree.test(e.command)

    if (isWork && PUSH_TO_DEFAULT.test(e.command)) {
      return {
        deny:
          'branch-guard: push в master/main в рабочих репо запрещён. Пушь в ветку задачи ' +
          '(`git push -u origin <branch>`), мерж в master только через MR.',
      }
    }
    if (isWork && UPSTREAM_TO_DEFAULT.test(e.command)) {
      return {
        deny:
          'branch-guard: upstream ветки задачи не должен смотреть на origin/master. ' +
          'Ставь `git push -u origin <branch>` — upstream будет origin/<branch>.',
      }
    }

    let command = e.command
    let note: string | undefined
    if (isWork && BRANCH_FROM_REMOTE_DEFAULT.test(command) && !/--no-track/.test(command)) {
      // without --no-track the new branch tracks origin/master; the flag has to go before
      // -b/-c, git takes whatever follows them as the branch name
      command = command
        .replace(/\b(checkout\s+)(-[bB]\b)/, (_, cmd, flag) => `${cmd}--no-track ${flag}`)
        .replace(/\b(switch\s+)(-[cC]\b)/, (_, cmd, flag) => `${cmd}--no-track ${flag}`)
        .replace(/\bworktree\s+add\b/, m => `${m} --no-track`)
      note =
        'branch-guard: добавил --no-track, чтобы ветка не трекала origin/master. ' +
        'Upstream выставится первым `git push -u origin <branch>`.'
    }

    const ran = await next(command === e.command ? e : { ...e, command })
    if (!/\bgit\b/.test(e.command)) return ran

    const t = await refreshStatus($, dir)
    const context = [...(ran.context ?? [])]
    if (note) context.push(note)
    if (isWork && t?.isWrong) {
      $.ui.toast(`⚠ ${t.branch} трекает ${t.upstream}`, { timeoutMs: 8000 })
      context.push(
        `branch-guard: ветка ${t.branch} трекает ${t.upstream}. Исправь сейчас: ` +
          `\`git -C ${dir} branch --unset-upstream\`, upstream выставит \`git push -u origin ${t.branch}\`.`,
      )
    }
    return context.length > (ran.context?.length ?? 0) && ran.deny === undefined ? { ...ran, context } : ran
  })

  on('turn.complete', async ($, e, next) => {
    void refreshStatus($, await $.session.cwd())
    return next(e)
  })
}
