import Component from '@glimmer/component';
import {action} from '@ember/object';
import {tracked} from '@glimmer/tracking';
import {dropTask} from 'ember-concurrency-decorators';
import {timeout} from 'ember-concurrency';

interface Args {
  onSubmit: (text: string) => Promise<void>;
}

const SUBMIT_DEBOUNCE = 1000;

export default class TranslationCommentForm extends Component<Args> {
  @tracked
  text = '';

  @tracked
  error = false;

  @dropTask
  *submitTask(event?: Event) {
    this.error = false;
    event?.preventDefault();

    try {
      yield timeout(SUBMIT_DEBOUNCE);
      yield this.args.onSubmit(this.text);

      this.text = '';
    } catch (error) {
      this.error = true;
    }
  }

  @action
  setText(event: KeyboardEvent) {
    const target = event.target as HTMLInputElement;
    this.text = target.value;
  }
}
