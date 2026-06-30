import Component from '@glimmer/component';
import {on} from '@ember/modifier';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
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
      {{inlineSvg '/assets/add.svg' class='button-icon'}}
      <span class='label'>{{t 'components.integrations_add_button.link'}}</span>
    </button>
  </template>
}
