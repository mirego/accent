import Component from '@glimmer/component';
import LogoBwSvg from 'accent-webapp/svgs/assets/logo-bw.svg';
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
      <LogoBwSvg class={{scopedClass 'logo'}} />

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

    <style scoped>
      .error-section {
        max-width: 400px;
        width: 100%;
        margin: 100px auto 30px;
        padding: 20px 20px 10px;
        box-shadow: 0 3px 21px var(--shadow-color);
        border: 1px solid var(--background-light-highlight);
        border-radius: var(--border-radius);
        background: var(--background-light);
        text-align: center;
      }

      .logo {
        display: block;
        width: 30px;
        height: 30px;
        margin: 0 auto 20px;
        fill: var(--background-light-highlight);
      }

      .footer {
        margin-top: 50px;
      }

      .header {
        display: flex;
        align-items: center;
        justify-content: center;
      }

      .status {
        margin-right: 15px;
        font-family: var(--font-monospace);
        font-size: 30px;
        font-weight: 300;
        color: var(--color-green);
      }

      .title {
        font-family: var(--font-monospace);
        font-size: 14px;
        font-style: italic;
        font-weight: 300;
        opacity: 0.7;
        color: var(--color-green);
      }

      .text {
        max-width: 220px;
        margin: 10px auto 50px;
        padding-top: 20px;
        border-top: 1px solid var(--background-light-highlight);
        font-size: 15px;
        color: var(--text-color-normal);
      }

      .link {
        font-size: 13px;
        color: var(--color-grey);
        text-decoration: none;
      }
      .link:focus,
      .link:hover {
        color: var(--color-green);
        text-decoration: underline;
      }

      .or {
        margin: 0 2px 0 5px;
        font-size: 12px;
        color: #bbb;
      }

      @media (max-width: 440px) {
        .error-section {
          margin-top: 40px;
        }
      }
    </style>
  </template>
}
