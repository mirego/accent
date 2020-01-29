import Component from '@glimmer/component';
import {action} from '@ember/object';
import {tracked} from '@glimmer/tracking';

interface Args {
  onSubmit: (text: string) => Promise<void>;
}

export default class TranslationCommentForm extends Component<Args> {
  @tracked
  text = '';

  @tracked
  loading = false;

  @tracked
  error = false;

  @action
  async submit(event?: Event) {
    event?.preventDefault();

    this.onLoading();

    try {
      await this.args.onSubmit(this.text);

      this.onSuccess();
    } catch (error) {
      this.onError();
    }
  }

  @action
  setText(text: string) {
    this.text = text;
  }

  private onLoading() {
    this.error = false;
    this.loading = true;
  }

  private onError() {
    this.loading = false;
    this.error = true;
  }

  private onSuccess() {
    this.loading = false;
    this.text = '';
  }
}
