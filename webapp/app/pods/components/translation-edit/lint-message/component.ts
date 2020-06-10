import {inject as service} from '@ember/service';
import IntlService from 'ember-intl/services/intl';
import Component from '@glimmer/component';
import {action} from '@ember/object';

interface Args {
  message: any;
  onReplaceText: (value: string) => void;
}

export default class LintMessage extends Component<Args> {
  @service('intl')
  intl: IntlService;

  @action
  replaceText() {
    this.args.onReplaceText(this.args.message.replacement.value);
  }

  get description() {
    return this.intl.t(
      `components.translation_edit.lint_message.checks.${this.args.message.check}`
    );
  }
}
