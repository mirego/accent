export enum Hooks {
  beforeAddTranslations = 'beforeAddTranslations',
  afterAddTranslations = 'afterAddTranslations',
  beforeExport = 'beforeExport',
  afterExport = 'afterExport',
  beforeSync = 'beforeSync',
  afterSync = 'afterSync',
}

export enum NamePattern {
  file = 'file',
  fileWithSlugSuffix = 'fileWithSlugSuffix',
  parentDirectory = 'parentDirectory',
}

export interface HookConfig {
  [Hooks.beforeAddTranslations]: string[];
  [Hooks.afterAddTranslations]: string[];
  [Hooks.beforeExport]: string[];
  [Hooks.afterExport]: string[];
  [Hooks.beforeSync]: string[];
  [Hooks.afterSync]: string[];
}

export interface DocumentConfig {
  format: string;
  source: string;
  target: string;
  namePattern?: NamePattern;
  hooks?: HookConfig;
}
