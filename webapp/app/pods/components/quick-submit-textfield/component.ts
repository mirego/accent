import Component from '@glimmer/component';
import {action} from '@ember/object';

const ENTER_KEY = 13;

interface Args {
  value: string | null | undefined;
  onFocus?: () => void;
  onBlur?: () => void;
  onKeyUp?: (event: KeyboardEvent) => void;
  onSubmit?: () => void;
}

export default class QuickSubmitTextfield extends Component<Args> {
  @action
  blur() {
    this.args.onBlur?.();
  }

  @action
  focus() {
    this.args.onFocus?.();
  }

  @action
  keyUp(event: KeyboardEvent) {
    this.args.onKeyUp?.(event);
  }

  @action
  keyDown(event: KeyboardEvent) {
    if (event.which === ENTER_KEY && (event.metaKey || event.ctrlKey)) {
      this.args.onSubmit?.();
    }
  }
}
