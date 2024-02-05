import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import {action} from '@ember/object';

interface Args {
  showFallback?: boolean;
}

export default class AccAvatarImg extends Component<Args> {
  @tracked
  showFallback = this.args.showFallback || false;

  @action
  fallbackImage() {
    this.showFallback = true;
  }
}
