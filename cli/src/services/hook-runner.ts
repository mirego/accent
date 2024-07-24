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
      const formatter = new Formatter();
      formatter.log(name, hooks);

      hooks.forEach((hook) => {
        try {
          const output = execSync(hook, {stdio: 'pipe'}).toString();
          if (output.length > 0) formatter.success(hook, output);
        } catch (error: any) {
          const output = error.stderr.toString();

          if (output.length > 0) {
            formatter.error(hook, [output]);
          } else {
            formatter.error(hook, [`Exit status: ${error.status}`]);
          }

          process.exit(error.status);
        }
      });
    }

    return this.document.refreshPaths();
  }
  /* eslint-disable @typescript-eslint/require-await */
}
