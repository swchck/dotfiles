import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register } from 'claude-code'

import type { EnvBandEnv } from '../types'

const env = atom({ plugin: 'env-band', key: 'env' } as const, null)
const prefix = atom({ plugin: 'env-band', key: 'prefix' } as const, null)
const isVpnUp = atom({ plugin: 'env-band', key: 'isVpnUp' } as const, null)

const VPN_PROBE_EVERY_MS = 60_000

const PROD_HINTS = [/--env[= ]+prod\b/i, /\bmb\.prod\.env\b/, /\bprod\.env\b/, /\/\/[\w.-]*\bprod\b[\w.-]*\//i, /(?:--host|-h)[= ]+\S*\bprod\b/i]
const STAGE_HINTS = [/--env[= ]+stage\b/i, /\bstage\.env\b/, /\/\/[\w.-]*\bstage\d*\b[\w.-]*/i]

const WRITES = [
  /\bmigrate(?:\.py)?\s+(?:apply|cleanup|up|down|restore)\b/,
  /\bbuild\.py\b[^;&|]*--apply\b/,
  /\bgoose\b[^;&|]*\s(?:up|down|reset|redo)\b/,
  /\b(?:ALTER|INSERT|DELETE|DROP|TRUNCATE|OPTIMIZE|RENAME|CREATE)\s+(?:TABLE|INTO|FROM|DATABASE|VIEW|MATERIALIZED|USER|ROLE|\w+\.)/i,
  /\bcurl\b[^;&|]*-X\s*(?:POST|PUT|PATCH|DELETE)\b/i,
]

function detectEnv(command: string, prodHost: RegExp | null): EnvBandEnv | null {
  if (prodHost?.test(command) || PROD_HINTS.some(re => re.test(command))) return 'PROD'
  if (STAGE_HINTS.some(re => re.test(command))) return 'STAGE'
  return null
}

function detectPrefix(command: string): string | null | undefined {
  const m = command.match(/--prefix[= ]+(?:"([^"]*)"|'([^']*)'|(\S+))/)
  if (m) return m[1] ?? m[2] ?? m[3] ?? null
  return undefined
}

async function probeVpn($: EngineInterface, url: string) {
  if (url === '') return true
  let isUp = false
  try {
    const r = await $.process.run(['curl', '-s', '-o', '/dev/null', '-m', '4', url], { timeoutMs: 6000 })
    isUp = r.exitCode === 0
  } catch {
    isUp = false
  }
  const was = await read($, isVpnUp)
  if (was !== isUp) {
    await update($, isVpnUp, () => isUp)
    if (was !== null) $.ui.toast(isUp ? 'VPN снова доступен' : 'VPN отвалился — прогоны на стенды встанут', { timeoutMs: 8000 })
  }
  return isUp
}

export const register: Register = (on, options) => {
  // both come from pluginConfigs in settings.json, so no work hostnames live in this file
  const probeUrl = String(options.vpnProbeUrl ?? '')
  const prodHost = options.prodHostPattern ? new RegExp(String(options.prodHostPattern)) : null

  on('session.start', async ($, e, next) => {
    if (probeUrl !== '') {
      void probeVpn($, probeUrl)
      $.clock.every(VPN_PROBE_EVERY_MS, () => void probeVpn($, probeUrl))
    }
    return next(e)
  })

  on('tool.call', { tool: 'Bash' }, async ($, e, next) => {
    if (e.tool !== 'Bash') return next(e)
    const target = detectEnv(e.command, prodHost)
    const pfx = detectPrefix(e.command)
    if (target !== null) await update($, env, () => target)
    if (pfx !== undefined) await update($, prefix, () => pfx)
    else if (target !== null && /\bmigrate(?:\.py)?\s+apply\b/.test(e.command)) await update($, prefix, () => null)

    if (target === 'PROD' && WRITES.some(re => re.test(e.command))) {
      const short = e.command.length > 160 ? `${e.command.slice(0, 160)}…` : e.command
      let answer = 'Отменить'
      try {
        answer = await $.ui.ask(`Команда пишет в PROD:\n${short}\nВыполнить?`, {
          options: ['Выполнить', 'Отменить'],
          header: 'PROD',
        })
      } catch {
        answer = 'Отменить'
      }
      if (answer !== 'Выполнить') {
        return { deny: `env-band: пользователь не подтвердил запись в PROD${answer === 'Отменить' ? '' : `: ${answer}`}` }
      }
    }

    const ran = await next(e)
    if (target !== null && ran.isError === true && !(await probeVpn($, probeUrl))) {
      return {
        ...ran,
        context: [...(ran.context ?? []), 'env-band: VPN недоступен. Не повторяй команду, скажи пользователю поднять VPN.'],
      }
    }
    return ran
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    const cur = await read($, env)
    const pfx = await read($, prefix)
    const vpn = await read($, isVpnUp)
    if (e.props.hasSurvey || (cur === null && vpn !== false)) return next(e)

    const { Box, Text } = $.ui.resolve(e)
    return (
      <Box>
        {cur !== null && (
          <Text bold color={cur === 'PROD' ? 'red' : 'green'}>
            {cur === 'PROD' ? ' PROD ' : ' STAGE '}
          </Text>
        )}
        {pfx !== null && <Text dimColor> prefix {JSON.stringify(pfx)}</Text>}
        {cur !== null && pfx === null && <Text dimColor> без префикса</Text>}
        <Text color={vpn === false ? 'red' : undefined} dimColor={vpn !== false}>
          {' · VPN '}
          {vpn === null ? '?' : vpn ? 'ok' : 'DOWN'}
        </Text>
      </Box>
    )
  })
}
