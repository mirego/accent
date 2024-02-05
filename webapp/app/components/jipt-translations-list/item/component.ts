import {equal} from '@ember/object/computed';
import Component from '@glimmer/component';

interface Args {
  translation: any;
}

export default class JIPTTranslationsListItem extends Component<Args> {
  @equal('translation.valueType', 'EMPTY')
  isTextEmpty: boolean;
}
