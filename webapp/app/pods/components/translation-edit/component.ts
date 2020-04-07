import {action} from '@ember/object';
import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';

interface Args {
  translation: any;
  project: any;
  permissions: Record<string, true>;
  onChangeText?: (text: string) => void;
  onUpdateText: (text: string) => Promise<void>;
  onCorrectConflict: (text: string) => Promise<void>;
  onUncorrectConflict: () => Promise<void>;
}

export default class TranslationEdit extends Component<Args> {
  @tracked
  isCorrectingConflict = false;

  @tracked
  isUncorrectingConflict = false;

  @tracked
  isUpdatingText = false;

  @tracked
  text = this.args.translation.correctedText;

  get samePreviousText() {
    return (
      this.args.translation.conflictedText ===
      this.args.translation.correctedText
    );
  }

  get hasTextNotChanged() {
    if (!this.args.translation) return false;

    return this.text === this.args.translation.correctedText;
  }

  @action
  async correctConflict() {
    this.isCorrectingConflict = true;

    await this.args.onCorrectConflict(this.text);

    this.isCorrectingConflict = false;
  }

  @action
  async uncorrectConflict() {
    this.isUncorrectingConflict = true;

    await this.args.onUncorrectConflict();

    this.isUncorrectingConflict = false;
  }

  @action
  async updateText() {
    this.isUpdatingText = true;

    await this.args.onUpdateText(this.text);

    this.isUpdatingText = false;
  }

  @action
  changeText(text: string) {
    this.text = text;

    this.args.onChangeText && this.args.onChangeText(text);
  }

  @action
  focusTextarea(element: HTMLElement) {
    element.querySelector('textarea')?.focus();
  }
}
