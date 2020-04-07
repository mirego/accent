import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import {action} from '@ember/object';

interface Args {
  revisionOperation: any;
}

export default class OperationsPeekItem extends Component<Args> {
  @tracked
  shouldShowStats = true;

  @tracked
  shouldShowOperations = false;

  @tracked
  shouldHideDetails = false;

  @action
  showStats() {
    this.shouldShowStats = true;
    this.shouldShowOperations = false;
    this.shouldHideDetails = false;
  }

  @action
  showOperations() {
    this.shouldShowStats = false;
    this.shouldShowOperations = true;
    this.shouldHideDetails = false;
  }

  @action
  hideDetails() {
    this.shouldShowStats = false;
    this.shouldShowOperations = false;
    this.shouldHideDetails = true;
  }
}
