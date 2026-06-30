import Component from '@glimmer/component';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import {scopedClass} from 'ember-scoped-css';
import {LinkTo} from '@ember/routing';
import t from 'ember-intl/helpers/t';
import {on} from '@ember/modifier';
import ApplicationFooter from 'accent-webapp/components/application-footer/index';

interface Args {
  status: string;
  title: string;
  text: string;
  isAuthenticated: boolean;
  onLogout?: () => void;
}

export default class ErrorSection extends Component<Args> {
  <template>
    <div class='error-section'>
      {{inlineSvg 'assets/logo-bw.svg' class=(scopedClass 'logo')}}

      <div class='header'>
        <h1 class='status'>
          {{@status}}
        </h1>

        <h2 class='title'>
          {{@title}}
        </h2>
      </div>

      <p class='text'>
        {{@text}}
      </p>

      <LinkTo @route='login' class='link'>
        {{t 'components.error_section.return'}}
      </LinkTo>

      {{#if @isAuthenticated}}
        <span class='or'>
          {{t 'components.error_section.or'}}
        </span>

        <button
          class='button button--red button--borderless'
          {{on 'click' @onLogout}}
        >
          {{t 'components.error_section.logout'}}
        </button>
      {{/if}}

      <div class='footer'>
        <ApplicationFooter />
      </div>
    </div>
  </template>
}
