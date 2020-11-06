import {action} from '@ember/object';
import {next} from '@ember/runloop';
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

  get latestActivity() {
    if (!this.args.translation) return;

    return this.args.translation.latestActivities.entries[0];
  }

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
  didUpdateCorrectedText(element: HTMLElement) {
    if (this.args.translation) {
      this.text = this.args.translation.correctedText;
      next(this, () => this.focusTextarea(element));
    }
  }

  @action
  changeText(text: string) {
    this.text = text;
    this.args.onChangeText?.(text);
  }

  @action
  focusTextarea(element: HTMLElement) {
    const focusable = element.querySelector('textarea');
    focusable?.focus();
    focusable?.setSelectionRange(this.text.length, this.text.length);
  }
}
