import Component from '@glimmer/component';
import {action} from '@ember/object';

interface Args {
  project: any;
  translations: any;
  onUpdateText: (translation: any, text: string) => Promise<void>;
}
export default class RelatedTranslationsList extends Component<Args> {
  @action
  focusTextarea(element: HTMLElement) {
    element.querySelector('textarea')?.focus();
  }
}
