import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import {action} from '@ember/object';

interface Args {
  prompt: any;
  error: boolean;
  project: any;
  onUpdate: ({
    content,
    name,
    quickAccess,
  }: {
    content: string;
    name: string;
    quickAccess: string;
  }) => Promise<void>;
}

export default class PromptUpdateForm extends Component<Args> {
  @tracked
  name = this.args.prompt.name;

  @tracked
  quickAccess = this.args.prompt.quickAccess;

  @tracked
  content = this.args.prompt.content;

  @tracked
  isSubmitting = false;

  @action
  async submit() {
    this.isSubmitting = true;

    const content = this.content;
    const quickAccess = this.quickAccess;
    const name = this.name;

    await this.args.onUpdate({content, name, quickAccess});

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
  setQuickAccess(selection: {emoji: string}) {
    this.quickAccess = selection.emoji;
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
