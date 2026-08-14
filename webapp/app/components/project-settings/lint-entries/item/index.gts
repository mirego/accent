import Component from '@glimmer/component';
import {service} from '@ember/service';
import IntlService from 'ember-intl/services/intl';
import AccBadge from 'accent-webapp/components/acc-badge/index';
import {on} from '@ember/modifier';
import {fn} from '@ember/helper';
import PencilSvg from 'accent-webapp/svgs/assets/pencil.svg';

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
        <PencilSvg class='button-icon' />
      </button>
    </div>

    <style scoped>
      .wrapper {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 10px;
        border-radius: var(--border-radius);
        border: 1px solid var(--content-background-border);
        font-size: 14px;
      }

      .type {
        text-transform: uppercase;
        font-size: 12px;
      }

      .value {
        font-family: var(--font-monospace);
      }

      .checks {
        display: flex;
        flex-wrap: wrap;
        gap: 6px;
        margin: 0;
        padding: 0;
        list-style: none;
      }

      .edit {
        margin-left: auto;
        flex-shrink: 0;
      }
    </style>
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
