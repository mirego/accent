import {tracked} from '@glimmer/tracking';
import Component from '@glimmer/component';
import {action} from '@ember/object';
import {htmlSafe} from '@ember/template';
import didInsert from '@ember/render-modifiers/modifiers/did-insert';
import {fn} from '@ember/helper';
import didUpdate from '@ember/render-modifiers/modifiers/did-update';

interface Args {
  correctedKeysPercentage: number;
}

const minimumTransitionDelay = 300;
const thresholdTransitionDelay = 200;
const transitionDelay = () =>
  Math.floor(Math.random() * Math.floor(thresholdTransitionDelay)) +
  minimumTransitionDelay;

export default class ReviewProgressBar extends Component<Args> {
  <template>
    {{! template-lint-disable no-inline-styles }}
    <div
      class='progress-bar'
      {{didInsert (fn this.setPercentage) @correctedKeysPercentage}}
      {{didUpdate (fn this.setPercentage) @correctedKeysPercentage}}
    >
      <div style={{this.progressStyles}} class='progress'></div>
    </div>
  </template>
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
