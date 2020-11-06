import Component from '@glimmer/component';
import {action} from '@ember/object';
import {restartableTask} from 'ember-concurrency-decorators';
import {timeout} from 'ember-concurrency';

const DEBOUNCE_OFFSET = 100; // ms
const ENTER_KEY = 13;

interface Args {
  value: string | null | undefined;
  onFocus?: () => void;
  onBlur?: () => void;
  onKeyUp?: (event: KeyboardEvent) => void;
  onSubmit?: () => void;
}

export default class QuickSubmitTextfield extends Component<Args> {
  @action
  blur() {
    this.args.onBlur?.();
  }

  @action
  focus() {
    this.args.onFocus?.();
  }

  @action
  keyUp(event: KeyboardEvent) {
    // eslint-disable-next-line @typescript-eslint/ban-ts-ignore
    // @ts-ignore
    this.debounceChange.perform(event);
  }

  @action
  keyDown(event: KeyboardEvent) {
    if (event.which === ENTER_KEY && (event.metaKey || event.ctrlKey)) {
      this.args.onSubmit?.();
    }
  }

  @restartableTask
  *debounceChange(event: KeyboardEvent) {
    yield timeout(DEBOUNCE_OFFSET);

    this.args.onKeyUp?.(event);
  }
}
