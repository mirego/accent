import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import {action} from '@ember/object';

export default class AccAvatarImg extends Component {
  @tracked
  showFallback: boolean;

  @action
  fallbackImage() {
    this.showFallback = true;
  }
}
