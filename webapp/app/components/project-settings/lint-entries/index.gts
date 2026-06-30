import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import {action} from '@ember/object';
import t from 'ember-intl/helpers/t';
import Item from 'accent-webapp/components/project-settings/lint-entries/item/index';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import {scopedClass} from 'ember-scoped-css';
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
        <div class='empty'>
          <div class='empty-hero'>
            <div>
              <h3 class='empty-hero-title'>{{t
                  'components.project_settings.lint_entries.empty_title'
                }}</h3>
              <p class='empty-hero-text'>{{t
                  'components.project_settings.lint_entries.empty_text'
                }}</p>
            </div>
          </div>

          <ul class='empty-types'>
            <li class='empty-type'>
              {{inlineSvg
                '/assets/filter.svg'
                class=(scopedClass 'empty-type-icon')
              }}
              <div>
                <strong>{{t
                    'components.project_settings.lint_entries.type_all'
                  }}</strong>
                <span>{{t
                    'components.project_settings.lint_entries.empty_type_all'
                  }}</span>
              </div>
            </li>

            <li class='empty-type'>
              {{inlineSvg
                '/assets/tag.svg'
                class=(scopedClass 'empty-type-icon')
              }}
              <div>
                <strong>{{t
                    'components.project_settings.lint_entries.type_term'
                  }}</strong>
                <span>{{t
                    'components.project_settings.lint_entries.empty_type_term'
                  }}</span>
              </div>
            </li>

            <li class='empty-type'>
              {{inlineSvg
                '/assets/key.svg'
                class=(scopedClass 'empty-type-icon')
              }}
              <div>
                <strong>{{t
                    'components.project_settings.lint_entries.type_key'
                  }}</strong>
                <span>{{t
                    'components.project_settings.lint_entries.empty_type_key'
                  }}</span>
              </div>
            </li>

            <li class='empty-type'>
              {{inlineSvg
                '/assets/language.svg'
                class=(scopedClass 'empty-type-icon')
              }}
              <div>
                <strong>{{t
                    'components.project_settings.lint_entries.type_language_tool_rule_id'
                  }}</strong>
                <span>{{t
                    'components.project_settings.lint_entries.empty_type_language_tool_rule_id'
                  }}</span>
              </div>
            </li>
          </ul>
        </div>
      {{/if}}

      {{#if (get @permissions 'createProjectLintEntry')}}
        <button
          type='button'
          class='button button--xl button--primary button--highlight'
          {{on 'click' this.openNew}}
        >
          {{inlineSvg '/assets/add.svg' class='button-icon'}}
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
  </template>
  @tracked
  editingEntry: LintEntry | null = null;

  @tracked
  creating = false;

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
