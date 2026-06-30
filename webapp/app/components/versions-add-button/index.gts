import Component from '@glimmer/component';
import {LinkTo} from '@ember/routing';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import t from 'ember-intl/helpers/t';

interface Args {
  project: any;
}

export default class VersionsAddButton extends Component<Args> {
  <template>
    <LinkTo
      @route='logged-in.project.versions.new'
      @model={{@project.id}}
      class='button button--primary button--xl button--highlight'
    >
      {{inlineSvg '/assets/add.svg' class='button-icon'}}
      <span class='label'>{{t 'components.versions_add_button.link'}}</span>
    </LinkTo>
  </template>
}
