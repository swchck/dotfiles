import type { Register } from 'claude-code'

type Lang = 'go' | 'py'
type Block = { line: number; lines: string[]; isIndented: boolean }

const RULES = '~/.claude/code-comments-rules.md'
const MAX_INLINE_LINES = 2
// doc comments may be longer, but past this they are a spec in the wrong place
const MAX_DOC_LINES = 6

const CYRILLIC = /[А-Яа-яЁё]/
const TAG = /\b(?:TODO|FIXME|HACK|XXX)\b/
const GO_DIRECTIVE = /^\/\/(?:go:|nolint|\s*\+build|line |export )/
const PY_PRAGMA = /^#\s*(?:type:|noqa|pragma|pylint:|fmt:|-\*-|!)/

function langOf(path: string): Lang | null {
  if (path.endsWith('.go')) return 'go'
  if (path.endsWith('.py')) return 'py'
  return null
}

function commentBody(raw: string, lang: Lang): string | null {
  const t = raw.trim()
  if (lang === 'go') return t.startsWith('//') && !GO_DIRECTIVE.test(t) ? t.slice(2).trim() : null
  return t.startsWith('#') && !PY_PRAGMA.test(t) ? t.slice(1).trim() : null
}

function blocks(text: string, lang: Lang): Block[] {
  const out: Block[] = []
  let cur: Block | null = null
  text.split('\n').forEach((raw, i) => {
    const body = commentBody(raw, lang)
    if (body === null) {
      cur = null
      return
    }
    if (cur === null) {
      cur = { line: i + 1, lines: [], isIndented: /^\s+/.test(raw) }
      out.push(cur)
    }
    cur.lines.push(body)
  })
  return out
}

function problems(text: string, lang: Lang): string[] {
  if (/^\/\/ Code generated .* DO NOT EDIT\.$/m.test(text)) return []
  const found: string[] = []
  for (const b of blocks(text, lang)) {
    const head = `строка ${b.line} «${b.lines[0]!.slice(0, 50)}»`
    const joined = b.lines.join(' ')
    if (CYRILLIC.test(joined)) found.push(`${head}: комментарий не на английском`)
    if (TAG.test(joined)) found.push(`${head}: TODO/FIXME/HACK/XXX запрещены — доделай или спроси пользователя`)
    if (b.isIndented && b.lines.length > MAX_INLINE_LINES) {
      found.push(`${head}: инлайн-комментарий ${b.lines.length} строк, максимум ${MAX_INLINE_LINES}`)
    }
    const isPackageDoc = /^Package \w+/.test(b.lines[0]!)
    if (!b.isIndented && !isPackageDoc && b.lines.length > MAX_DOC_LINES) {
      found.push(`${head}: doc-комментарий ${b.lines.length} строк — оставь одну фразу, детали в package doc или в код`)
    }
  }
  return found
}

export const register: Register = on => {
  on('tool.call', async ($, e, next) => {
    if (e.tool !== 'Edit' && e.tool !== 'Write') return next(e)
    const lang = langOf(e.file_path)
    if (lang === null) return next(e)

    const ran = await next(e)
    if (ran.deny !== undefined || ran.isError === true) return ran

    const written = e.tool === 'Edit' ? e.new_string : e.content
    const found = problems(written, lang)
    if (found.length === 0) return ran

    $.ui.toast(`comment-gate: ${found.length} замечаний в ${e.file_path.split('/').pop()}`)
    const note =
      `comment-gate: в ${e.file_path} комментарии нарушают ${RULES}. ` +
      `Исправь сразу, до следующего шага (сократи, удали пересказ кода, переведи на английский):\n- ` +
      found.join('\n- ')
    return { ...ran, context: [...(ran.context ?? []), note] }
  })
}
