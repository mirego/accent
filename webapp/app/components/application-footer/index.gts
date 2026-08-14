import Component from '@glimmer/component';
import {action} from '@ember/object';
import config from 'accent-webapp/config/environment';
import {service} from '@ember/service';
import IntlService from 'ember-intl/services/intl';
import {on} from '@ember/modifier';
import MoonSvg from 'accent-webapp/svgs/assets/moon.svg';
import SunSvg from 'accent-webapp/svgs/assets/sun.svg';
import eq from 'ember-truth-helpers/helpers/eq';
import t from 'ember-intl/helpers/t';

export default class ApplicationFooter extends Component {
  <template>
    <footer class='footer'>
      <div class='inner'>
        <div class='left'>
          <div class='left-meta'>
            <span class='version'>
              {{this.version}}
            </span>

            <div class='button-themes'>
              <button
                class='button-theme button-theme--moon'
                {{on 'click' this.toggleDark}}
              >
                <MoonSvg />
              </button>
              <button
                class='button-theme button-theme--sun'
                {{on 'click' this.toggleLight}}
              >
                <SunSvg />
              </button>
            </div>
          </div>

          <div class='select'>
            <select {{on 'change' this.changeLanguage}}>
              <option
                selected={{eq this.currentLocale 'en-us'}}
                value='en-us'
              >{{t
                  'components.application_footer.language_select.english'
                }}</option>
              <option
                selected={{eq this.currentLocale 'fr-ca'}}
                value='fr-ca'
              >{{t
                  'components.application_footer.language_select.french'
                }}</option>
            </select>
          </div>
        </div>
      </div>
    </footer>

    <style scoped>
      @charset "UTF-8";
      .footer {
        color: var(--color-grey);
        font-size: 12px;
        text-align: right;
        padding-bottom: 10px;
      }

      .inner {
        display: flex;
        flex-direction: column;
        justify-content: flex-start;
        max-width: var(--screen-lg);
      }

      .left {
        display: flex;
        align-items: center;
        justify-content: space-between;
      }

      .left-meta {
        display: flex;
        align-items: center;
      }

      .right {
        display: flex;
        align-items: center;
        gap: 10px;
      }

      .select {
        position: relative;
      }
      .select select {
        font-size: 11px;
        appearance: none;
        border: 1px solid var(--background-light-highlight);
        background: var(--background-light);
        color: color-mix(in srgb, var(--text-color-normal) 70%, transparent);
        border-radius: var(--border-radius);
        padding: 4px 19px 4px 7px;
      }

      .select::after {
        display: block;
        pointer-events: none;
        cursor: pointer;
        content: '›';
        position: absolute;
        top: 50%;
        right: 6px;
        font-size: 140%;
        transform: translateY(-50%) rotate(90deg);
        color: var(--text-color-normal);
      }

      .version {
        font-family: var(--font-monospace);
        font-size: 10px;
      }

      .button-themes {
        display: flex;
        margin-left: 10px;
        transition: opacity 0.2s ease-in-out;
      }

      .button-theme {
        padding: 0 3px;
        margin-left: 5px;
        background: none;
        opacity: 0.2;
        color: var(--text-color-normal);
        transition:
          color 0.2s ease-in-out,
          opacity 0.2s ease-in-out,
          transform 0.2s ease-in;
      }
      .button-theme:focus,
      .button-theme:hover {
        outline: none;
      }
      .button-theme:hover {
        opacity: 1;
      }

      .button-theme--moon:hover {
        transform: rotate(-20deg);
        color: #5660e4;
      }
      .button-theme--moon :global(svg) {
        width: 13px;
        height: 13px;
      }

      .button-theme--sun:hover {
        transform: translateY(-3px);
        color: #dcbc18;
      }
      .button-theme--sun :global(svg) {
        width: 16px;
        height: 16px;
      }

      .external-link {
        color: var(--color-black);
        text-decoration: none;
      }
      .external-link:focus,
      .external-link:hover {
        text-decoration: underline;
      }

      @media (max-width: 800px) {
        .footer {
          display: none;
        }
      }
    </style>
  </template>
  @service('intl')
  declare intl: IntlService;

  get version() {
    return config.version === '__VERSION__' ? 'dev' : config.version;
  }

  get currentLocale() {
    return localStorage.getItem('locale') || 'en-us';
  }

  toggleDark() {
    document.documentElement.setAttribute('data-theme', 'dark');
    localStorage.setItem('theme', 'dark');
  }

  toggleLight() {
    document.documentElement.setAttribute('data-theme', 'light');
    localStorage.setItem('theme', 'light');
  }

  @action
  changeLanguage(event: any) {
    const locale = event.target.value;

    localStorage.setItem('locale', locale);
    this.intl.setLocale(locale);
  }
}
