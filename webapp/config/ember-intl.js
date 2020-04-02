/* eslint-env node */

'use strict';

module.exports = function () {
  return {
    locales: null,
    fallbackLocale: null,
    inputPath: 'app/locales',
    autoPolyfill: false,
    disablePolyfill: false,
    publicOnly: false,
    errorOnNamedArgumentMismatch: false,
    errorOnMissingTranslations: false,
    stripEmptyTranslations: false,
    requiresTranslation: () => true,
  };
};
