import Component from '@glimmer/component';
import {action} from '@ember/object';
import {tracked} from '@glimmer/tracking';
import {timeout, dropTask} from 'ember-concurrency';
import {MutationResponse} from 'accent-webapp/services/apollo-mutate';

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
    return this.submitTask.isRunning;
  }

  submitTask = dropTask(async (event?: Event) => {
    this.error = false;
    event?.preventDefault();

    await timeout(SUBMIT_DEBOUNCE);
    const response = await this.args.onSubmit(this.text);

    if (response.errors) {
      this.error = true;
    } else {
      this.text = '';
    }
  });

  @action
  setText(event: KeyboardEvent) {
    const target = event.target as HTMLInputElement;
    this.text = target.value;
  }
}
