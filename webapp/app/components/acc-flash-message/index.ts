import Component from '@glimmer/component';
import {action} from '@ember/object';
import {readOnly} from '@ember/object/computed';

interface Args {
  flash: {
    exiting: boolean;
    type: string;
    destroyMessage: () => void;
  };
}

export default class FlashMessage extends Component<Args> {
  @readOnly('args.flash.exiting')
  isExiting: boolean;

  @readOnly('args.flash.type')
  type: 'info' | 'success' | 'error' | 'socket';

  get iconPath() {
    switch (this.type) {
      case 'success':
        return 'assets/check.svg';
      case 'error':
        return 'assets/x.svg';
      case 'socket':
        return 'assets/activity.svg';
      default:
        return null;
    }
  }

  @action
  close() {
    const flash = this.args.flash;

    if (flash) flash.destroyMessage();
  }
}
