import Component from '@glimmer/component';
import {LinkTo} from '@ember/routing';
import AddSvg from 'accent-webapp/svgs/assets/add.svg';
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
      <AddSvg class='button-icon' />
      <span class='label'>{{t 'components.versions_add_button.link'}}</span>
    </LinkTo>

    <style scoped>
      @media (max-width: 800px) {
        .label {
          display: none;
        }
      }
    </style>
  </template>
}
