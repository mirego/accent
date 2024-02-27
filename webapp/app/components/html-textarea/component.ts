import {action} from '@ember/object';
import Component from '@glimmer/component';
import pell from 'pell';
import {timeout, restartableTask} from 'ember-concurrency';

const DEBOUNCE_OFFSET = 1000; // ms

interface PellInstance {
  exec: (fun: string, element: string) => void;
}

interface Args {
  value: string;
  options: object;
  onChange: (text: string) => void;
}

const clear = (pell: PellInstance) => {
  return () => {
    if (!window) return;
    const selection = window.getSelection();
    if (!selection) return;

    if (selection.toString()) {
      const linesToDelete = selection.toString().split('\n').join('<br>');
      pell.exec('formatBlock', '<div>');
      document.execCommand('insertHTML', false, `<div>${linesToDelete}</div>`);
    } else {
      pell.exec('formatBlock', '<div>');
    }
  };
};

export default class HTMLTextarea extends Component<Args> {
  content: HTMLElement | null;

  @action
  initWysiwyg(element: HTMLElement) {
    const pellInstance = pell.init({
      element,
      actions: [
        'bold',
        'italic',
        'underline',
        'strikethrough',
        'quote',
        'olist',
        'ulist',
        'code',
        'line',
        'link',
        {
          icon: '✗',
          title: 'Clear',
          result: clear(pell)
        }
      ],
      onChange: (text) => {
        this.debounceChangeTask.perform(text);
      }
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

  debounceChangeTask = restartableTask(async (text: string) => {
    await timeout(DEBOUNCE_OFFSET);

    this.args.onChange(text);
  });
}
