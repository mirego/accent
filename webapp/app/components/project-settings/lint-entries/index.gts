import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import {action} from '@ember/object';
import {service} from '@ember/service';
import t from 'ember-intl/helpers/t';
import IntlService from 'ember-intl/services/intl';
import EmptyHero from 'accent-webapp/components/empty-hero/index';
import Item from 'accent-webapp/components/project-settings/lint-entries/item/index';
import AddSvg from 'accent-webapp/svgs/assets/add.svg';
import FilterSvg from 'accent-webapp/svgs/assets/filter.svg';
import KeySvg from 'accent-webapp/svgs/assets/key.svg';
import LanguageSvg from 'accent-webapp/svgs/assets/language.svg';
import TagSvg from 'accent-webapp/svgs/assets/tag.svg';
import {get} from '@ember/helper';
import {on} from '@ember/modifier';
import FormModal from 'accent-webapp/components/project-settings/lint-entries/form-modal/index';

interface LintEntry {
  id: string;
  checkIds: string[];
  type: string;
  value: string | null;
}

interface Args {
  lintEntries: {entries: LintEntry[]};
  permissions: Record<string, boolean>;
  onCreate: (attrs: object) => Promise<{errors: unknown}>;
  onUpdate: (attrs: object) => Promise<{errors: unknown}>;
  onDelete: (id: string) => Promise<{errors: unknown}>;
}

export default class LintEntries extends Component<Args> {
  <template>
    <div class='wrapper'>
      <h2 class='title'>
        {{t 'components.project_settings.lint_entries.title'}}
      </h2>
      <p class='text'>
        {{t 'components.project_settings.lint_entries.help'}}
      </p>

      {{#if @lintEntries.entries.length}}
        <ul class='list'>
          {{#each @lintEntries.entries key='id' as |lintEntry|}}
            <li>
              <Item @lintEntry={{lintEntry}} @onEdit={{this.openEdit}} />
            </li>
          {{/each}}
        </ul>
      {{else}}
        <EmptyHero
          @title={{t 'components.project_settings.lint_entries.empty_title'}}
          @text={{t 'components.project_settings.lint_entries.empty_text'}}
          @features={{this.features}}
        />
      {{/if}}

      {{#if (get @permissions 'createProjectLintEntry')}}
        <button
          type='button'
          class='button button--xl button--primary button--highlight'
          {{on 'click' this.openNew}}
        >
          <AddSvg class='button-icon' />
          {{t 'components.project_settings.lint_entries.add_button'}}
        </button>
      {{/if}}

      {{#if this.showModal}}
        <FormModal
          @lintEntry={{this.editingEntry}}
          @onClose={{this.closeModal}}
          @onCreate={{@onCreate}}
          @onUpdate={{@onUpdate}}
          @onDelete={{@onDelete}}
        />
      {{/if}}
    </div>

    <style scoped>
      .wrapper {
        display: flex;
        flex-direction: column;
        margin-top: 25px;
      }

      .title {
        font-weight: bold;
        font-size: 17px;
        padding-bottom: 4px;
      }

      .text {
        display: block;
        font-size: 13px;
        margin-bottom: 12px;
      }

      .list {
        display: flex;
        flex-direction: column;
        gap: 10px;
        margin-bottom: 20px;
        max-width: 600px;
      }
    </style>
  </template>
  @service('intl')
  declare intl: IntlService;

  @tracked
  editingEntry: LintEntry | null = null;

  @tracked
  creating = false;

  get features() {
    return [
      {
        icon: FilterSvg,
        title: this.intl.t('components.project_settings.lint_entries.type_all'),
        text: this.intl.t(
          'components.project_settings.lint_entries.empty_type_all'
        )
      },
      {
        icon: TagSvg,
        title: this.intl.t(
          'components.project_settings.lint_entries.type_term'
        ),
        text: this.intl.t(
          'components.project_settings.lint_entries.empty_type_term'
        )
      },
      {
        icon: KeySvg,
        title: this.intl.t('components.project_settings.lint_entries.type_key'),
        text: this.intl.t(
          'components.project_settings.lint_entries.empty_type_key'
        )
      },
      {
        icon: LanguageSvg,
        title: this.intl.t(
          'components.project_settings.lint_entries.type_language_tool_rule_id'
        ),
        text: this.intl.t(
          'components.project_settings.lint_entries.empty_type_language_tool_rule_id'
        )
      }
    ];
  }

  get showModal() {
    return this.creating || this.editingEntry !== null;
  }

  @action
  openNew() {
    this.editingEntry = null;
    this.creating = true;
  }

  @action
  openEdit(lintEntry: LintEntry) {
    this.creating = false;
    this.editingEntry = lintEntry;
  }

  @action
  closeModal() {
    this.creating = false;
    this.editingEntry = null;
  }
}
