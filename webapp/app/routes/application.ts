import {service} from '@ember/service';
import Route from '@ember/routing/route';
import raven from 'raven-js';
import config from 'accent-webapp/config/environment';
import Session from 'accent-webapp/services/session';
import IntlService from 'ember-intl/services/intl';
import RouterService from '@ember/routing/router-service';
import translationsForEnUs from 'virtual:ember-intl/translations/en-us';
import translationsForFrCa from 'virtual:ember-intl/translations/fr-ca';

export default class ApplicationRoute extends Route {
  @service('session')
  declare session: Session;

  @service('intl')
  declare intl: IntlService;

  @service('router')
  declare router: RouterService;

  async beforeModel() {
    this.intl.addTranslations('en-us', translationsForEnUs);
    this.intl.addTranslations('fr-ca', translationsForFrCa);

    const locale = localStorage.getItem('locale') || 'en-us';
    this.intl.setLocale(locale);

    raven.config(config.SENTRY.DSN).install();

    await this.session.login();
  }
}
