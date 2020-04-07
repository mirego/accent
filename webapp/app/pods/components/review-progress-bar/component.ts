import {tracked} from '@glimmer/tracking';
import Component from '@glimmer/component';
import {action} from '@ember/object';
import {htmlSafe} from '@ember/string';

interface Args {
  correctedKeysPercentage: number;
}

const minimumTransitionDelay = 300;
const thresholdTransitionDelay = 200;
const transitionDelay = () =>
  Math.floor(Math.random() * Math.floor(thresholdTransitionDelay)) +
  minimumTransitionDelay;

export default class ReviewProgressBar extends Component<Args> {
  @tracked
  percentage = 0;

  @action
  setPercentage() {
    setTimeout(
      () => (this.percentage = this.args.correctedKeysPercentage),
      transitionDelay()
    );
  }

  get progressStyles() {
    let percentage = this.percentage;

    if (percentage < 1 && percentage !== 0) percentage = 1;

    return htmlSafe(`width: ${percentage}%`);
  }
}
