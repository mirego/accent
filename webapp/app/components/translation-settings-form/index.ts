import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import {action} from '@ember/object';

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
