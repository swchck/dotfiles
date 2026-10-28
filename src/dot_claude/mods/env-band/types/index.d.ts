export type EnvBandEnv = 'PROD' | 'STAGE'

declare module 'claude-code' {
  interface PluginState {
    'env-band': {
      env: EnvBandEnv | null
      prefix: string | null
      isVpnUp: boolean | null
    }
  }
}
