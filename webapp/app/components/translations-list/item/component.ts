import {action} from '@ember/object';
import {equal} from '@ember/object/computed';
import Component from '@glimmer/component';
import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';
import {tracked} from '@glimmer/tracking';

interface Args {
  translation: any;
  project: any;
  revisions: any[];
  onUpdateText: (translation: any, editText: string) => Promise<void>;
}

export default class TranslationsListItem extends Component<Args> {
  @tracked
  isSaving = false;

  @tracked
  isInEditMode = false;

  @tracked
  inputDisabled = this.args.translation.isRemoved;

  @tracked
  editText = this.args.translation.correctedText;

  @equal('args.translation.valueType', 'EMPTY')
  isTextEmpty: boolean;

  @equal('args.translation.valueType', 'NULL')
  isTextNull: boolean;

  translationKey = parsedKeyProperty(this.args.translation.key);

  get revisionSlug() {
    return (
      this.args.translation.revision.slug ||
      this.args.translation.revision.language.slug
    );
  }

  get revisionTextDirRtl() {
    return this.args.translation.revision.rtl !== null
      ? this.args.translation.revision.rtl
      : this.args.translation.revision.language.rtl;
  }

  @action
  changeTranslationText(text: string) {
    this.editText = text;
  }

  @action
  async save() {
    this.isSaving = true;

    await this.args.onUpdateText(this.args.translation, this.editText);

    this.isSaving = false;
    this.isInEditMode = !this.isInEditMode;
  }

  @action
  toggleEdit() {
    this.editText = this.args.translation.correctedText;
    this.isInEditMode = !this.isInEditMode;
  }

  @action
  focusTextarea(element: HTMLElement) {
    element.querySelector('textarea')?.focus();
  }

  @action
  onUpdateText(value: string) {
    this.editText = value;
    this.inputDisabled = false;
  }

  @action
  onUpdatingText() {
    this.inputDisabled = true;
  }
}
