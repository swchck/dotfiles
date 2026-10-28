export type PlainTalkMode = boolean

declare module 'claude-code' {
  interface PluginState {
    'plain-talk': { isOn: PlainTalkMode }
  }
}
