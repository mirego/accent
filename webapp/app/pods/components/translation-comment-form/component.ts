import Component from '@glimmer/component';
import {action} from '@ember/object';
import {tracked} from '@glimmer/tracking';
import {dropTask} from 'ember-concurrency-decorators';
import {timeout} from 'ember-concurrency';
import {MutationResponse} from 'accent-webapp/services/apollo-mutate';
import {taskFor} from 'ember-concurrency-ts';

interface Args {
  value?: string;
  onSubmit: (text: string) => Promise<MutationResponse>;
}

const SUBMIT_DEBOUNCE = 1000;

export default class TranslationCommentForm extends Component<Args> {
  @tracked
  text = this.args.value || '';

  @tracked
  error = false;

  get isSubmitting() {
    return taskFor(this.submitTask).isRunning;
  }

  @dropTask
  *submitTask(event?: Event): any {
    this.error = false;
    event?.preventDefault();

    yield timeout(SUBMIT_DEBOUNCE);
    const response = yield this.args.onSubmit(this.text);

    if (response.errors) {
      this.error = true;
    } else {
      this.text = '';
    }
  }

  @action
  setText(event: KeyboardEvent) {
    const target = event.target as HTMLInputElement;
    this.text = target.value;
  }
}
