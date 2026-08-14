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

    <style scoped>
      .text {
        width: 100%;
        min-height: 140px;
        margin-top: 30px;
        padding: 15px;
        resize: vertical;
        outline: 0;
        border: 1px solid var(--background-light-highlight);
        background: var(--background-light);
        font-family: var(--font-monospace);
        font-size: 12px;
      }

      .label {
        display: block;
        margin-top: 10px;
        color: var(--color-grey);
        font-size: 13px;
        font-style: italic;
        text-align: right;
      }
    </style>
  </template>
}
