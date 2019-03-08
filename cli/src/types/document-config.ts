export enum Hooks {
  beforeAddTranslations = 'beforeAddTranslations',
  afterAddTranslations = 'afterAddTranslations',
  beforeExport = 'beforeExport',
  afterExport = 'afterExport',
  beforeSync = 'beforeSync',
  afterSync = 'afterSync'
}

export interface HookConfig {
  [Hooks.beforeAddTranslations]: string[]
  [Hooks.afterAddTranslations]: string[]
  [Hooks.beforeExport]: string[]
  [Hooks.afterExport]: string[]
  [Hooks.beforeSync]: string[]
  [Hooks.afterSync]: string[]
}

export interface DocumentConfig {
  name: string
  language: string
  format: string
  source: string
  target: string
  hooks?: HookConfig
}
