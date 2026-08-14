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

    <style scoped>
      .progress-bar {
        width: 100%;
        height: 4px;
        background: var(--background-light);
        border-radius: 1px;
      }

      .progress {
        height: 4px;
        width: 0;
        background: currentColor;
        border-radius: 1px;
        transition: width 500ms ease-in-out;
      }
      .progress:after {
        width: 100%;
        content: '';
        height: 1px;
        background: transparent;
        box-shadow: 3px 2px 4px currentColor;
        display: block;
        opacity: 0.7;
      }
    </style>
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
