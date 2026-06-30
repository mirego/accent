import Component from '@glimmer/component';
import {LinkTo} from '@ember/routing';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
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
      {{inlineSvg '/assets/language.svg' class='button-icon'}}
      {{t 'components.documents_machine_translations_button.link'}}
    </LinkTo>
  </template>
}
