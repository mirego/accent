import {action} from '@ember/object';
import Component from '@glimmer/component';
import pell from 'pell';
import {restartableTask} from 'ember-concurrency-decorators';
import {timeout} from 'ember-concurrency';

const DEBOUNCE_OFFSET = 1000; // ms

interface Args {
  value: string;
  options: object;
  onChange: (text: string) => void;
}

export default class HTMLTextarea extends Component<Args> {
  content: HTMLElement | null;

  @action
  initWysiwyg(element: HTMLElement) {
    const pellInstance = pell.init({
      element,
      actions: [],
      onChange: (text) => {
        // eslint-disable-next-line @typescript-eslint/ban-ts-ignore
        // @ts-ignore
        this.debounceChange.perform(text);
      },
    });

    this.content = pellInstance.querySelector('.pell-content');
    this._setValue();
  }

  _setValue() {
    if (!this.content) return;
    const val = this.args.value;

    if (this.content.innerHTML !== val && typeof val !== 'undefined') {
      this.content.innerHTML = val;
    }
  }

  @restartableTask
  *debounceChange(text: string) {
    yield timeout(DEBOUNCE_OFFSET);

    this.args.onChange(text);
  }
}
