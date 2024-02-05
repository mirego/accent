import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import {action} from '@ember/object';

interface Args {
  error: boolean;
  project: any;
  onCreate: ({
    content,
    name,
    quickAccess,
  }: {
    content: string;
    name: string;
    quickAccess: string;
  }) => Promise<void>;
}

export default class PromptCreateForm extends Component<Args> {
  @tracked
  name = '';

  @tracked
  quickAccess = '';

  @tracked
  content = '';

  @tracked
  isSubmitting = false;

  @action
  async submit() {
    this.isSubmitting = true;

    const content = this.content;
    const quickAccess = this.quickAccess;
    const name = this.name;

    await this.args.onCreate({content, name, quickAccess});

    if (!this.isDestroyed) this.isSubmitting = false;
  }

  @action
  setName(event: Event) {
    const target = event.target as HTMLInputElement;

    this.name = target.value;
  }

  @action
  setContent(event: Event) {
    const target = event.target as HTMLInputElement;

    this.content = target.value;
  }

  @action
  setQuickAccess(selection: string) {
    this.quickAccess = selection;
  }

  @action
  clearQuickAccess() {
    this.quickAccess = '';
  }

  @action
  focusTextarea(element: HTMLElement) {
    element.querySelector('input')?.focus();
  }
}
