import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import {action} from '@ember/object';
import t from 'ember-intl/helpers/t';
import AccSelect from 'accent-webapp/components/acc-select/index';
import {fn} from '@ember/helper';
import {on} from '@ember/modifier';
import AsyncButton from 'accent-webapp/components/async-button/index';

interface Args {
  translation: any;
  permissions: Record<string, true>;
  onUpdateSettings: (attrs: {
    plural: boolean;
    locked: boolean;
    placeholders: string[];
    fileIndex: number | null;
    fileComment: string | null;
    valueType: string;
    sourceTranslationId: string | null;
  }) => Promise<void>;
}

const VALUE_TYPES = [
  'string',
  'html',
  'plural',
  'boolean',
  'null',
  'array',
  'empty',
  'integer',
  'float'
];

export default class TranslationSettingsForm extends Component<Args> {
  <template>
    <div class='form'>
      <div class='formItem'>
        <label class='formItem-label'>
          {{t 'components.translation_settings_form.value_type_label'}}
        </label>
        <AccSelect
          @searchEnabled={{false}}
          @selected={{this.valueTypeValue}}
          @options={{this.mappedValueTypes}}
          @onchange={{fn this.setValueType}}
        />
      </div>

      <div class='formItem'>
        <label class='formItem-label'>
          {{t 'components.translation_settings_form.placeholders_label'}}
        </label>
        <input
          value={{this.placeholders}}
          class='textInput'
          {{on 'input' (fn this.setPlaceholders)}}
        />
        <p class='formItem-help'>
          {{t 'components.translation_settings_form.placeholders_help'}}
        </p>
      </div>

      <div class='formItem'>
        <label class='formItem-label'>
          {{t 'components.translation_settings_form.file_index_label'}}
        </label>
        <input
          type='number'
          value={{this.fileIndex}}
          class='textInput'
          {{on 'input' (fn this.setFileIndex)}}
        />
      </div>

      <div class='formItem'>
        <label class='formItem-label'>
          {{t 'components.translation_settings_form.file_comment_label'}}
        </label>
        <textarea
          class='textInput textInput--textarea'
          {{on 'input' (fn this.setFileComment)}}
        >{{this.fileComment}}</textarea>
      </div>

      <div class='formItem'>
        <label class='formItem-label formItem-checkbox'>
          <input
            type='checkbox'
            checked={{this.plural}}
            {{on 'change' (fn this.setPlural)}}
          />
          {{t 'components.translation_settings_form.plural_label'}}
        </label>
      </div>

      <div class='formItem'>
        <label class='formItem-label formItem-checkbox'>
          <input
            type='checkbox'
            checked={{this.locked}}
            {{on 'change' (fn this.setLocked)}}
          />
          {{t 'components.translation_settings_form.locked_label'}}
        </label>
        <p class='formItem-help'>
          {{t 'components.translation_settings_form.locked_help'}}
        </p>
      </div>

      <div class='formItem'>
        <label class='formItem-label'>
          {{t
            'components.translation_settings_form.source_translation_id_label'
          }}
        </label>
        <input
          value={{this.sourceTranslationId}}
          class='textInput'
          {{on 'input' (fn this.setSourceTranslationId)}}
        />
        <p class='formItem-help'>
          {{t
            'components.translation_settings_form.source_translation_id_help'
          }}
        </p>
      </div>

      <div class='formActions'>
        <AsyncButton
          class='button button--filled'
          @loading={{this.isSubmitting}}
          @onClick={{fn this.submit}}
        >
          {{t 'components.translation_settings_form.save_button'}}
        </AsyncButton>
      </div>
    </div>
  </template>
  get mappedValueTypes() {
    return VALUE_TYPES.map((value) => ({label: value, value}));
  }

  get valueTypeValue() {
    return this.mappedValueTypes.find(({value}) => value === this.valueType);
  }

  @tracked
  plural = this.args.translation.plural;

  @tracked
  locked = this.args.translation.locked;

  @tracked
  valueType = this.args.translation.valueType?.toLowerCase();

  @tracked
  placeholders = (this.args.translation.placeholders || []).join(', ');

  @tracked
  fileIndex: string = this.args.translation.fileIndex?.toString() ?? '';

  @tracked
  fileComment = this.args.translation.fileComment ?? '';

  @tracked
  sourceTranslationId = this.args.translation.sourceTranslation?.id ?? '';

  @tracked
  isSubmitting = false;

  @action
  setPlural(event: Event) {
    this.plural = (event.target as HTMLInputElement).checked;
  }

  @action
  setLocked(event: Event) {
    this.locked = (event.target as HTMLInputElement).checked;
  }

  @action
  setValueType({value}: {value: string}) {
    this.valueType = value;
  }

  @action
  setPlaceholders(event: Event) {
    this.placeholders = (event.target as HTMLInputElement).value;
  }

  @action
  setFileIndex(event: Event) {
    this.fileIndex = (event.target as HTMLInputElement).value;
  }

  @action
  setFileComment(event: Event) {
    this.fileComment = (event.target as HTMLInputElement).value;
  }

  @action
  setSourceTranslationId(event: Event) {
    this.sourceTranslationId = (event.target as HTMLInputElement).value;
  }

  @action
  async submit() {
    this.isSubmitting = true;

    const placeholders = this.placeholders
      .split(',')
      .map((p: string) => p.trim())
      .filter((p: string) => p !== '');

    const fileIndex =
      this.fileIndex !== '' ? parseInt(this.fileIndex, 10) : null;

    await this.args.onUpdateSettings({
      plural: this.plural,
      locked: this.locked,
      valueType: this.valueType.toUpperCase(),
      placeholders,
      fileIndex: isNaN(fileIndex as number) ? null : fileIndex,
      fileComment: this.fileComment || null,
      sourceTranslationId: this.sourceTranslationId || null
    });

    if (!this.isDestroyed) this.isSubmitting = false;
  }
}
