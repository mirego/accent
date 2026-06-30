import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import {action} from '@ember/object';
import {service} from '@ember/service';
import {dropTask} from 'ember-concurrency';
import IntlService from 'ember-intl/services/intl';
import AccModal from 'accent-webapp/components/acc-modal/index';
import {on} from '@ember/modifier';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import {scopedClass} from 'ember-scoped-css';
import t from 'ember-intl/helpers/t';
import AccSelect from 'accent-webapp/components/acc-select/index';
import AsyncButton from 'accent-webapp/components/async-button/index';
import perform from 'ember-concurrency/helpers/perform';

interface LintEntry {
  id: string;
  checkIds: string[];
  type: string;
  value: string | null;
}

interface Option {
  label: string;
  value: string;
}

interface Args {
  lintEntry?: LintEntry | null;
  onClose: () => void;
  onCreate: (attrs: object) => Promise<{errors: unknown}>;
  onUpdate: (attrs: object) => Promise<{errors: unknown}>;
  onDelete: (id: string) => Promise<{errors: unknown}>;
}

const TYPE_VALUES = ['ALL', 'TERM', 'KEY', 'LANGUAGE_TOOL_RULE_ID'];

const CHECK_VALUES = [
  'spelling',
  'leading_spaces',
  'double_spaces',
  'first_letter_case',
  'apostrophe_as_single_quote',
  'three_dots_ellipsis',
  'same_trailing_character',
  'trailing_space',
  'placeholder_count',
  'url_count'
];

export default class LintEntriesFormModal extends Component<Args> {
  <template>
    <AccModal @onClose={{@onClose}} @small={{true}}>
      <div class='wrapper'>
        <button type='button' class='closeButton' {{on 'click' @onClose}}>
          {{inlineSvg '/assets/x.svg' class=(scopedClass 'closeButton-icon')}}
        </button>

        <strong class='title'>{{this.title}}</strong>

        <label class='field'>
          <span class='label'>{{t
              'components.project_settings.lint_entries.type_label'
            }}</span>
          <AccSelect
            @customSelect={{true}}
            @options={{this.typeOptions}}
            @selected={{this.selectedType}}
            @onchange={{this.setType}}
          />
        </label>

        {{#unless this.isSpellcheckRule}}
          <label class='field'>
            <span class='label'>{{t
                'components.project_settings.lint_entries.checks_label'
              }}</span>
            <AccSelect
              @multi={{true}}
              @options={{this.checkOptions}}
              @selected={{this.selectedChecks}}
              @onchange={{this.setChecks}}
            />
          </label>
        {{/unless}}

        {{#if this.showValueField}}
          <div class='field'>
            <span class='labelRow'>
              <span class='label'>{{this.valueLabel}}</span>
              {{#if this.isSpellcheckRule}}
                <a
                  href='https://community.languagetool.org/rule/list'
                  target='_blank'
                  rel='noopener noreferrer'
                  class='labelLink'
                >
                  {{t
                    'components.project_settings.lint_entries.language_tool_rules_link'
                  }}
                </a>
              {{/if}}
            </span>
            <input
              type='text'
              value={{this.value}}
              class='textInput'
              {{on 'input' this.setValue}}
            />
          </div>
        {{/if}}

        <div class='actions'>
          {{#if this.isEditMode}}
            <AsyncButton
              @onClick={{perform this.delete}}
              @loading={{this.delete.isRunning}}
              class='button button--red button--filled'
            >
              {{t 'components.project_settings.lint_entries.delete_button'}}
            </AsyncButton>
          {{/if}}

          <AsyncButton
            @onClick={{perform this.save}}
            @loading={{this.save.isRunning}}
            class='button button--filled'
          >
            {{t 'components.project_settings.lint_entries.save_button'}}
          </AsyncButton>
        </div>
      </div>
    </AccModal>
  </template>
  @service('intl')
  declare intl: IntlService;

  @tracked
  value: string = this.args.lintEntry?.value || '';

  @tracked
  type: string = this.args.lintEntry?.type || 'TERM';

  @tracked
  checkIds: string[] = this.args.lintEntry
    ? [...this.args.lintEntry.checkIds]
    : [];

  get isEditMode() {
    return Boolean(this.args.lintEntry);
  }

  get title(): string {
    return this.intl.t(
      this.isEditMode
        ? 'components.project_settings.lint_entries.edit_title'
        : 'components.project_settings.lint_entries.new_title'
    );
  }

  get typeOptions(): Option[] {
    return TYPE_VALUES.map((value) => ({
      label: this.intl.t(
        `components.project_settings.lint_entries.type_${value.toLowerCase()}`
      ),
      value
    }));
  }

  get checkOptions(): Option[] {
    return CHECK_VALUES.map((value) => ({
      label: this.intl.t(
        `components.translation_edit.lint_message.title_checks.${value.toUpperCase()}`
      ),
      value
    }));
  }

  get selectedType(): Option | undefined {
    return this.typeOptions.find((option) => option.value === this.type);
  }

  get showValueField(): boolean {
    return this.type !== 'ALL';
  }

  get valueLabel(): string {
    return this.intl.t(
      `components.project_settings.lint_entries.value_label_${this.type.toLowerCase()}`
    );
  }

  get isSpellcheckRule(): boolean {
    return this.type === 'LANGUAGE_TOOL_RULE_ID';
  }

  get selectedChecks(): Option[] {
    return this.checkOptions.filter((option) =>
      this.checkIds.includes(option.value)
    );
  }

  @action
  setType(option: Option) {
    this.type = option.value;
    if (!this.showValueField) this.value = '';
    if (this.isSpellcheckRule) this.checkIds = ['spelling'];
  }

  @action
  setChecks(options: Option[]) {
    this.checkIds = options.map((option) => option.value);
  }

  @action
  setValue(event: Event) {
    this.value = (event.target as HTMLInputElement).value;
  }

  save = dropTask(async () => {
    const attrs = {
      checkIds: this.checkIds,
      type: this.type,
      value: this.value === '' ? null : this.value
    };

    const lintEntry = this.args.lintEntry;
    const response = lintEntry
      ? await this.args.onUpdate({id: lintEntry.id, ...attrs})
      : await this.args.onCreate(attrs);

    if (!response.errors) this.args.onClose();
  });

  delete = dropTask(async () => {
    const lintEntry = this.args.lintEntry;
    if (!lintEntry) return;

    const message = this.intl.t(
      'components.project_settings.lint_entries.delete_confirm'
    );
    // eslint-disable-next-line no-alert
    if (!window.confirm(message)) return;

    const response = await this.args.onDelete(lintEntry.id);

    if (!response.errors) this.args.onClose();
  });
}
