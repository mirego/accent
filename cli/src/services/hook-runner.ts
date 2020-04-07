// Vendor
import {execSync} from 'child_process';

// Formatters
import Formatter from './formatters/hook-runner';

// Types
import {HookConfig, Hooks} from '../types/document-config';
import Document from './document';

export default class HookRunner {
  readonly hooks?: HookConfig;
  private readonly document: Document;

  constructor(document: Document) {
    this.document = document;
    this.hooks = document.config.hooks;
  }

  /* eslint-disable @typescript-eslint/require-await */
  async run(name: Hooks) {
    if (!this.hooks) return null;
    const hooks = this.hooks[name];

    if (hooks) {
      new Formatter().log(name, hooks);

      hooks.forEach(execSync);
    }

    return this.document.refreshPaths();
  }
  /* eslint-disable @typescript-eslint/require-await */
}
