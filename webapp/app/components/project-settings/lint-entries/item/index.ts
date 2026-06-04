import Component from '@glimmer/component';
import {service} from '@ember/service';
import IntlService from 'ember-intl/services/intl';

interface LintEntry {
  id: string;
  checkIds: string[];
  type: string;
  value: string | null;
}

interface Args {
  lintEntry: LintEntry;
  onEdit: (lintEntry: LintEntry) => void;
}

export default class LintEntriesItem extends Component<Args> {
  @service('intl')
  declare intl: IntlService;

  get checkLabels(): string[] {
    return this.args.lintEntry.checkIds.map((checkId) =>
      this.intl.t(
        `components.translation_edit.lint_message.title_checks.${checkId.toUpperCase()}`
      )
    );
  }
}
