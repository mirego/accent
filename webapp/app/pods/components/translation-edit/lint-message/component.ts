import Component from '@glimmer/component';
import {action} from '@ember/object';
import {gt} from '@ember/object/computed';

const REPLACEMENTS_LIMIT = 10;

interface Context {
  text: string;
  offset: number;
  length: number;
}

interface Args {
  message: any;
  onReplaceText: (
    context: Context,
    replacement: {label: string; value: string}
  ) => void;
}

export default class LintMessage extends Component<Args> {
  @gt('mappedReplacements', 1)
  multipleReplacements: boolean;

  get selectedReplacement() {
    const replacement = this.args.message.replacements[0];

    return {
      label: replacement.value,
      value: replacement.value,
    };
  }

  get mappedReplacements() {
    return this.args.message.replacements
      .slice(0, REPLACEMENTS_LIMIT)
      .map((replacement: any) => {
        return {
          label: replacement.value,
          value: replacement.value,
        };
      });
  }

  @action
  replaceTextSelected() {
    const replacement = this.selectedReplacement;

    this.args.onReplaceText(this.args.message.context, replacement);
  }

  @action
  replaceText({value}: {value: string}) {
    const replacement = this.args.message.replacements.find(
      (replacement: {label: string; value: string}) => {
        return replacement.value === value;
      }
    );

    this.args.onReplaceText(this.args.message.context, replacement);
  }
}
