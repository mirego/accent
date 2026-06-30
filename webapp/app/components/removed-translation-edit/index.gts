import Component from '@glimmer/component';
import t from 'ember-intl/helpers/t';

interface Args {
  translation: any;
}

export default class RemovedTranslationEdit extends Component<Args> {
  <template>
    <div class='text'>{{@translation.correctedText}}</div>

    <span class='label'>
      {{t 'components.removed_translation_edit.cant_edit'}}
    </span>
  </template>
}
