import {action} from '@ember/object';
import Component from '@glimmer/component';
import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';

interface Args {
  selectedTranslationId: string | null;
  groupedTranslation: {
    key: string;
    translations: any[];
  };
  onFocus: (id: string) => void;
}

export default class ConflictsListGroup extends Component<Args> {
  translationKey = parsedKeyProperty(this.args.groupedTranslation.key);

  get masterTranslation() {
    return this.args.groupedTranslation.translations[0];
  }

  get isFocused() {
    return this.masterTranslation.id === this.args.selectedTranslationId;
  }

  @action
  handleFocus() {
    this.args.onFocus(this.masterTranslation.id);
  }
}
