import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import {action} from '@ember/object';

interface Args {
  version: any;
  error: boolean;
  project: any;
  onUpdate: ({tag, name}: {tag: string; name: string}) => Promise<void>;
}

export default class VersionUpdateForm extends Component<Args> {
  @tracked
  name = this.args.version.name;

  @tracked
  tag = this.args.version.tag;

  @tracked
  isSubmitting = false;

  @action
  async submit() {
    this.isSubmitting = true;

    const tag = this.tag;
    const name = this.name;

    await this.args.onUpdate({tag, name});

    if (!this.isDestroyed) this.isSubmitting = false;
  }

  @action
  setName(event: Event) {
    const target = event.target as HTMLInputElement;

    this.name = target.value;
  }

  @action
  setTag(event: Event) {
    const target = event.target as HTMLInputElement;

    this.tag = target.value;
  }

  @action
  focusTextarea(element: HTMLElement) {
    element.querySelector('input')?.focus();
  }
}
