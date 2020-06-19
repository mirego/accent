import {action} from '@ember/object';
import {equal} from '@ember/object/computed';
import Component from '@glimmer/component';

import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';
import {tracked} from '@glimmer/tracking';

interface Args {
  translation: any;
  project: any;
  onUpdateText: (translation: any, editText: string) => Promise<void>;
}

const MAX_TEXT_LENGTH = 600;

export default class TranslationsListItem extends Component<Args> {
  @tracked
  isSaving = false;

  @tracked
  isInEditMode = false;

  @tracked
  editText = this.args.translation.correctedText;

  @equal('args.translation.valueType', 'EMPTY')
  isTextEmpty: boolean;

  translationKey = parsedKeyProperty(this.args.translation.key);

  @action
  changeTranslationText(text: string) {
    this.editText = text;
  }

  get displayText() {
    const text = this.args.translation.correctedText;

    if (text.length < MAX_TEXT_LENGTH) return text;

    return `${text.substring(0, MAX_TEXT_LENGTH - 1)}…`;
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
}
