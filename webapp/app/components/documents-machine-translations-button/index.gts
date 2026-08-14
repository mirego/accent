import Component from '@glimmer/component';
import {LinkTo} from '@ember/routing';
import LanguageSvg from 'accent-webapp/svgs/assets/language.svg';
import t from 'ember-intl/helpers/t';

interface Args {
  project: any;
}

export default class DocumentsMachineTranslationsButton extends Component<Args> {
  <template>
    <LinkTo
      @route='logged-in.project.files.new-machine-translations'
      @model={{@project.id}}
      class='button button--borderLess button--filled button--grey local-button'
    >
      <LanguageSvg class='button-icon' />
      {{t 'components.documents_machine_translations_button.link'}}
    </LinkTo>

    <style scoped>
      :global(.button.button--filled).local-button {
        margin-left: 15px;
      }
    </style>
  </template>
}
