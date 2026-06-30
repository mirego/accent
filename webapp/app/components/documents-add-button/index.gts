import Component from '@glimmer/component';
import {LinkTo} from '@ember/routing';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import t from 'ember-intl/helpers/t';

interface Args {
  project: any;
}

export default class DocumentsAddButton extends Component<Args> {
  <template>
    <LinkTo
      @route='logged-in.project.files.new-sync'
      @model={{@project.id}}
      class='button button--primary button--xl button--highlight'
    >
      {{inlineSvg '/assets/add.svg' class='button-icon'}}
      {{t 'components.documents_add_button.link'}}
    </LinkTo>
  </template>
}
