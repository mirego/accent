import Component from '@glimmer/component';
import {service} from '@ember/service';
import IntlService from 'ember-intl/services/intl';
import AccBadge from 'accent-webapp/components/acc-badge/index';
import {on} from '@ember/modifier';
import {fn} from '@ember/helper';
import inlineSvg from 'accent-webapp/helpers/inline-svg';

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
  <template>
    <div class='wrapper'>
      <strong class='type'>{{@lintEntry.type}}</strong>

      {{#if @lintEntry.value}}
        <span class='value'>{{@lintEntry.value}}</span>
      {{/if}}

      {{#if this.checkLabels.length}}
        <ul class='checks'>
          {{#each this.checkLabels key='@identity' as |checkLabel|}}
            <li>
              <AccBadge>{{checkLabel}}</AccBadge>
            </li>
          {{/each}}
        </ul>
      {{/if}}

      <button
        type='button'
        class='button button--iconOnly button--filled button--white button--link edit'
        {{on 'click' (fn @onEdit @lintEntry)}}
      >
        {{inlineSvg 'assets/pencil.svg' class='button-icon'}}
      </button>
    </div>
  </template>
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
