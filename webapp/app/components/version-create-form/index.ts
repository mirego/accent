import Component from '@glimmer/component';
import {action} from '@ember/object';
import {tracked} from '@glimmer/tracking';

interface Args {
  error: boolean;
  project: any;
  onCreate: (args: object) => Promise<void>;
}

export default class VersionCreateForm extends Component<Args> {
  @tracked
  name = '';

  @tracked
  tag = '';

  @tracked
  copyOnUpdateTranslation = true;

  @tracked
  isCreating = false;

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
  setCopyOnUpdateTranslation(event: Event) {
    const target = event.target as HTMLInputElement;
    this.copyOnUpdateTranslation = target.checked;
  }

  @action
  async submit() {
    this.isCreating = true;

    await this.args.onCreate({
      tag: this.tag,
      name: this.name,
      copyOnUpdateTranslation: this.copyOnUpdateTranslation
    });

    this.isCreating = false;
  }

  @action
  focusTextarea(element: HTMLElement) {
    element.querySelector('input')?.focus();
  }
}
