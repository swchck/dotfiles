import { atom, read, update } from 'claude-code'
import type { Register } from 'claude-code'

const isOn = atom({ plugin: 'plain-talk', key: 'isOn' } as const, false)

const ASKS_PLAIN =
  /(прощ[ея]|простыми словами|простой|не понял|не понимаю|непонятн|нихуя не понятно|без воды|нейрослоп|много текста|лаконичн|короче|кратко|по существу)/i
const ASKS_STEPS = /(дай (мне )?(команд|порядок|четк|чётк)|порядок (релиза|выкатки|действий)|конкретно (мне )?скажи)/i
const THREAD_LINK = /(slack\.com\/archives\/|\/merge_requests\/\d+)/
const ASKS_REPLY = /(что (мне )?ответить|ответь|отпиш|напиши (ответ|сообщение|в тред)|сформулируй|для ответов)/i

const PLAIN_RULE = [
  'plain-talk: пользователь хочет коротко и простыми словами. Правила ответа:',
  '1. Первая строка — прямой ответ или вывод, одно-два предложения, без терминов, которые не пояснены.',
  '2. Дальше максимум 5 коротких пунктов: что именно сломано/сделать, где, какой командой или запросом.',
  '3. Без вступлений, пересказа контекста, оговорок, конструкций «не просто X, а Y», таблиц ради таблиц.',
  '4. Если вопрос «почему» — объясни механизм на примере с конкретными числами из этого случая.',
].join('\n')

const STEPS_RULE =
  'plain-talk: нужен порядок действий. Ответ — нумерованный список «шаг: репозиторий → команда», ' +
  'каждая команда в своём блоке bash. Никаких пояснений между шагами, кроме одной строки, если шаг опасен.'

const REPLY_RULE =
  'plain-talk: ответ уйдёт в Slack или GitLab от имени пользователя. Сначала разберись по существу, ' +
  'потом черновик ответа пиши через скилл doppelganger. Ничего не отправляй сам.'

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({
      name: 'plain',
      description: 'Toggle short plain-language answers for this session',
    })
    return next(e)
  })

  on('command.run', { command: 'plain' }, async $ => {
    const now = await update($, isOn, v => !v)
    $.ui.status(now ? 'plain: on' : undefined)
    return { text: now ? 'plain-talk: короткие ответы простым языком включены' : 'plain-talk: выключено' }
  })

  on('prompt.submit', async ($, e, next) => {
    if (e.origin.kind === 'plugin') return next(e)
    const rules: string[] = []
    if ((await read($, isOn)) || ASKS_PLAIN.test(e.text)) rules.push(PLAIN_RULE)
    if (ASKS_STEPS.test(e.text)) rules.push(STEPS_RULE)
    if ((THREAD_LINK.test(e.text) && ASKS_REPLY.test(e.text)) || /doppelganger/i.test(e.text)) rules.push(REPLY_RULE)
    if (rules.length === 0) return next(e)
    return next({ ...e, context: [...(e.context ?? []), rules.join('\n\n')] })
  })
}
