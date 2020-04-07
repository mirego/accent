import Component from '@glimmer/component';
import {action} from '@ember/object';
import {tracked} from '@glimmer/tracking';

interface Args {
  error: any;
  project: any;
  onCreate: ({name, tag}: {name: string; tag: string}) => Promise<void>;
}

export default class VersionCreateForm extends Component<Args> {
  @tracked
  name = '';

  @tracked
  tag = '';

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
  async submit() {
    this.isCreating = true;

    const tag = this.tag;
    const name = this.name;

    await this.args.onCreate({tag, name});

    this.isCreating = false;
  }

  @action
  focusTextarea(element: HTMLElement) {
    element.querySelector('input')?.focus();
  }
}
