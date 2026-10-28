export type ShipCheckRepo = {
  root: string
  name: string
  branch: string
  upstream: string | null
  base: string
  behind: number
  ahead: number
  dirty: number
  conflicts: number
  isRebasing: boolean
  head: string
}

export type ShipCheckRun = { isOk: boolean; head: string }

export type ShipCheckKind = 'tests' | 'lint' | 'app' | 'review'

export type ShipCheckRuns = Partial<Record<ShipCheckKind, ShipCheckRun>>

declare module 'claude-code' {
  interface PluginState {
    'ship-check': {
      roots: string[]
      repos: Record<string, ShipCheckRepo>
      runs: Record<string, ShipCheckRuns>
    }
  }
}
