import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import {action} from '@ember/object';

interface Args {
  version: any;
  error: boolean;
  project: any;
  onUpdate: (args: {
    tag: string;
    name: string;
    copyOnUpdateTranslation: boolean;
  }) => Promise<void>;
}

export default class VersionUpdateForm extends Component<Args> {
  @tracked
  name = this.args.version.name;

  @tracked
  tag = this.args.version.tag;

  @tracked
  copyOnUpdateTranslation = this.args.version.copyOnUpdateTranslation;

  @tracked
  isSubmitting = false;

  @action
  async submit() {
    this.isSubmitting = true;

    await this.args.onUpdate({
      tag: this.tag,
      name: this.name,
      copyOnUpdateTranslation: this.copyOnUpdateTranslation
    });

    if (!this.isDestroyed) this.isSubmitting = false;
  }

  @action
  setCopyOnUpdateTranslation(event: Event) {
    const target = event.target as HTMLInputElement;
    this.copyOnUpdateTranslation = target.checked;
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
