import Component from '@glimmer/component';
import {action} from '@ember/object';
import config from 'accent-webapp/config/environment';
import {service} from '@ember/service';
import IntlService from 'ember-intl/services/intl';
import {on} from '@ember/modifier';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
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
                {{inlineSvg '/assets/moon.svg'}}
              </button>
              <button
                class='button-theme button-theme--sun'
                {{on 'click' this.toggleLight}}
              >
                {{inlineSvg '/assets/sun.svg'}}
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
