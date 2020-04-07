import Raven from 'raven-js';
import config from 'accent-webapp/config/environment';

export const initialize = (application) => {
  if (config.SENTRY.DSN) {
    Raven.config(config.SENTRY.DSN).install();

    const lookupName = 'service:raven';
    const service = application.lookup
      ? application.lookup(lookupName)
      : application.container.lookup(lookupName);
    service.enableGlobalErrorCatching();
  }
};

export default {
  name: 'raven-setup',
  initialize,
};
