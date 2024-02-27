/* eslint-env node */

'use strict';

module.exports = function () {
  return {
    fallbackLocale: null,
    inputPath: 'app/locales',
    publicOnly: false,
    errorOnNamedArgumentMismatch: false,
    errorOnMissingTranslations: false,
    stripEmptyTranslations: false,
    requiresTranslation: () => true
  };
};
