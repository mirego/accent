import Component from '@glimmer/component';
import {on} from '@ember/modifier';
import AddSvg from 'accent-webapp/svgs/assets/add.svg';
import t from 'ember-intl/helpers/t';

interface Args {
  onClick: () => void;
}

export default class IntegrationsAddButton extends Component<Args> {
  <template>
    <button
      class='button button--primary button--xl button--highlight'
      {{on 'click' @onClick}}
      type='button'
    >
      <AddSvg class='button-icon' />
      <span class='label'>{{t 'components.integrations_add_button.link'}}</span>
    </button>

    <style scoped>
      @media (max-width: 800px) {
        .label {
          display: none;
        }
      }
    </style>
  </template>
}
