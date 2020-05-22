import {action} from '@ember/object';
import {empty} from '@ember/object/computed';
import Component from '@glimmer/component';

import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';
import {tracked} from '@glimmer/tracking';

interface Args {
  fullscreen: boolean;
  revision: any;
  permissions: Record<string, true>;
  project: any;
  conflict: any;
  onCorrect: (conflict: any, textInput: string) => Promise<void>;
}

export default class ConflictItem extends Component<Args> {
  @empty('args.conflict.conflictedText')
  emptyPreviousText: boolean;

  @tracked
  textInput = this.args.conflict.correctedText;

  @tracked
  loading = false;

  @tracked
  error = false;

  @tracked
  resolved = false;

  @tracked
  active = false;

  conflictKey = parsedKeyProperty(this.args.conflict.key);

  get samePreviousText() {
    return (
      this.args.conflict.conflictedText === this.args.conflict.correctedText
    );
  }

  @action
  changeTranslationText(text: string) {
    this.textInput = text;
  }

  @action
  async correct() {
    this.onLoading();

    try {
      await this.args.onCorrect(this.args.conflict, this.textInput);
      this.onCorrectSuccess();
    } catch (error) {
      this.onError();
    }
  }

  @action
  inputBlur() {
    this.active = false;
  }

  @action
  inputFocus() {
    this.active = true;
  }

  @action
  toggleActive() {
    this.active = true;
  }

  @action
  focusTextarea(element: HTMLElement) {
    element.querySelector('textarea')?.focus();
  }

  private onLoading() {
    this.error = false;
    this.loading = true;
  }

  private onError() {
    this.error = true;
    this.loading = false;
  }

  private onCorrectSuccess() {
    this.resolved = true;
    this.loading = false;
  }
}
