import Component from '@glimmer/component';
import {htmlSafe} from '@ember/string';

interface Args {
  correctedKeysPercentage: number;
}

export default class ReviewProgressBar extends Component<Args> {
  get progressStyles() {
    let percentage = this.args.correctedKeysPercentage;

    if (percentage < 1 && percentage !== 0) percentage = 1;

    return htmlSafe(`width: ${percentage}%`);
  }
}
