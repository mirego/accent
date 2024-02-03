import {action} from '@ember/object';
import {next} from '@ember/runloop';
import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';

interface Args {
  translation: any;
  text: string | null;
  project: any;
  permissions: Record<string, true>;
  onChangeText?: (text: string) => void;
  onUpdateText: (text: string) => Promise<void>;
  onCorrectConflict: (text: string) => Promise<void>;
  onUncorrectConflict: (text: string) => Promise<void>;
}

export default class TranslationEdit extends Component<Args> {
  @tracked
  isCorrectingConflict = false;

  @tracked
  isUncorrectingConflict = false;

  @tracked
  isUpdatingText = false;

  @tracked
  inputDisabled = this.args.translation.isRemoved;

  @tracked
  text = this.args.translation.correctedText;

  get latestActivity() {
    if (!this.args.translation) return;

    return this.args.translation.latestActivities.entries[0];
  }

  get revisionSlug() {
    return (
      this.args.translation.revision.slug ||
      this.args.translation.revision.language.slug
    );
  }

  get revisionTextDirRtl() {
    return this.args.translation.revision.rtl != null
      ? this.args.translation.revision.rtl
      : this.args.translation.revision.language.rtl;
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
  setOriginalText() {
    this.text = this.args.translation.correctedText;
    this.args.onChangeText?.(this.text);
  }

  @action
  async correctConflict() {
    this.isCorrectingConflict = true;

    await this.args.onCorrectConflict(this.text);

    this.isCorrectingConflict = false;
  }

  @action
  onUpdateText(value: string) {
    this.text = value;
    this.inputDisabled = false;
  }

  @action
  onUpdatingText() {
    this.inputDisabled = true;
  }

  @action
  async uncorrectConflict() {
    this.isUncorrectingConflict = true;

    await this.args.onUncorrectConflict(this.text);

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
    if (!this.text) return;
    const focusable = element.querySelector('textarea');
    focusable?.focus();
    focusable?.setSelectionRange(this.text.length, this.text.length);
  }
}
