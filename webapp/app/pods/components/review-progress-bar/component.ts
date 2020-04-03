import {tracked} from '@glimmer/tracking';
import Component from '@glimmer/component';
import {action} from '@ember/object';
import {htmlSafe} from '@ember/string';

interface Args {
  correctedKeysPercentage: number;
}

const TRANSITION_DELAY = 300;

export default class ReviewProgressBar extends Component<Args> {
  @tracked
  percentage = 0;

  @action
  setPercentage() {
    setTimeout(
      () => (this.percentage = this.args.correctedKeysPercentage),
      TRANSITION_DELAY
    );
  }

  get progressStyles() {
    let percentage = this.percentage;

    if (percentage < 1 && percentage !== 0) percentage = 1;

    return htmlSafe(`width: ${percentage}%`);
  }
}
