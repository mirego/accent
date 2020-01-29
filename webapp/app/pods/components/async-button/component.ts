import Component from '@glimmer/component';
import {action} from '@ember/object';

interface Args {
  onClick: () => void;
  loading?: boolean;
  disabled?: boolean;
}

export default class AsyncButton extends Component<Args> {
  get disabled() {
    return this.args.disabled || this.args.loading;
  }

  @action
  onClick() {
    if (this.args.disabled) return;

    if (typeof this.args.onClick === 'function') this.args.onClick();
  }
}
