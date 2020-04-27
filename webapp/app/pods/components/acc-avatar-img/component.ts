import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import {action} from '@ember/object';

export default class AccAvatarImg extends Component {
  @tracked
  showFallback = false;

  @action
  fallbackImage() {
    this.showFallback = true;
  }
}
