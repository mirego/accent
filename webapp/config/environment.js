/* eslint-env node */

'use strict';

// eslint-disable-next-line complexity
module.exports = function (environment) {
  const sentryDsn =
    process.env.NODE_ENV === 'production'
      ? process.env.WEBAPP_SENTRY_DSN || '__WEBAPP_SENTRY_DSN__'
      : process.env.WEBAPP_SENTRY_DSN;

  const ENV = {
    version: '__VERSION__',
    modulePrefix: 'accent-webapp',
    podModulePrefix: 'accent-webapp/pods',
    environment,
    rootURL: '/',
    locationType: 'auto',
  };

  ENV.SENTRY = {
    DSN: sentryDsn,
  };

  ENV.EmberENV = {
    EXTEND_PROTOTYPES: false,
    LOG_VERSION: false,
  };

  ENV.APP = {
    LOCAL_STORAGE: {
      SESSION_NAMESPACE: 'accent-session',
    },
  };

  ENV.API = {
    WS_ENABLED: true,
    AUTHENTICATION_PATH: '/auth',
    HOOKS_PATH: '/hooks/{0}?project_id={1}&authorization={2}',
    PROJECT_PATH: '/projects/{0}',
    MACHINE_TRANSLATIONS_TRANSLATE_FILE_PROJECT_PATH:
      '/machine-translations/translate-file?project_id={0}&language={1}&to_language_id={2}&document_format={3}',
    SYNC_PEEK_PROJECT_PATH:
      '/sync/peek?project_id={0}&language={1}&sync_type={2}',
    SYNC_PROJECT_PATH: '/sync?project_id={0}&language={1}&sync_type={2}',
    MERGE_PEEK_PROJECT_PATH:
      '/add-translations/peek?project_id={0}&language={1}&merge_type={2}&merge_options={3}',
    MERGE_REVISION_PATH:
      '/add-translations?project_id={0}&language={1}&merge_type={2}&merge_options={3}',
    EXPORT_DOCUMENT: '/export',
    JIPT_EXPORT_DOCUMENT: '/jipt-export',
    PERCENTAGE_REVIEWED_BADGE_SVG_PROJECT_PATH:
      '/{0}/percentage_reviewed_badge.svg',
    REVIEWED_BADGE_SVG_PROJECT_PATH: '/{0}/reviewed_badge.svg',
    TRANSLATIONS_BADGE_SVG_PROJECT_PATH: '/{0}/translations_badge.svg',
    CONFLICTS_BADGE_SVG_PROJECT_PATH: '/{0}/conflicts_badge.svg',
    JIPT_SCRIPT_PATH: '/static/jipt/index.js',
  };

  ENV.flashMessageDefaults = {
    timeout: 5000,
    destroyOnClick: false,
    extendedTimeout: 300,
    priority: 200,
    sticky: false,
    showProgress: false,

    // service defaults
    type: 'info',
    types: ['info', 'success', 'error', 'socket'],
    injectionFactories: [],
  };

  if (environment === 'test') {
    ENV.locationType = 'none';

    ENV.APP.LOG_ACTIVE_GENERATION = false;
    ENV.APP.LOG_VIEW_LOOKUPS = false;

    ENV.APP.rootElement = '#ember-testing';
    ENV.APP.autoboot = false;

    ENV.API.WS_ENABLED = false;

    ENV.APP.LOCAL_STORAGE.SESSION_NAMESPACE = 'accent-session-test';
  }

  return ENV;
};
