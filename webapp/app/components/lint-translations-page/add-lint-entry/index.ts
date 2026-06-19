import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import {action} from '@ember/object';

interface Args {
  message: {
    check: string;
    text: string;
    offset: number | null;
    length: number | null;
  };
  permissions: object;
  create: (lintEntry: object) => Promise<{errors: string[] | null}>;
}

export default class LintTranslationsPageAddLintEntry extends Component<Args> {
  @tracked
  displayMenu = false;

  get isSpelling() {
    return this.args.message.check === 'SPELLING';
  }

  get spellingTermValue() {
    if (this.args.message.offset == null || this.args.message.length == null)
      return;

    return this.args.message.text.substring(
      this.args.message.offset,
      this.args.message.offset + this.args.message.length
    );
  }

  @action
  toggleMenu() {
    this.displayMenu = !this.displayMenu;
  }

  @action
  async create(type: string, value: string | null) {
    await this.args.create({
      checkIds: [this.args.message.check.toLowerCase()],
      type,
      value
    });

    this.displayMenu = false;
  }
}
