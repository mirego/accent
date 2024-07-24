import Component from '@glimmer/component';
import {action} from '@ember/object';
import config from 'accent-webapp/config/environment';
import {inject as service} from '@ember/service';
import IntlService from 'ember-intl/services/intl';

export default class ApplicationFooter extends Component {
  @service('intl')
  intl: IntlService;

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
