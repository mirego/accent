/* eslint-env node */

'use strict';

const EmberApp = require('ember-cli/lib/broccoli/ember-app');
const target = require('./config/targets');

module.exports = function(defaults) {
  const app = new EmberApp(defaults, {
    hinting: false,
    vendorFiles: {
      'jquery.js': null
    },
    autoprefixer: {
      browsers: target.browsers
    },
    babel: {
      sourceMaps: 'inline',
      plugins: ['transform-object-rest-spread']
    },
    'ember-cli-babel': {
      includePolyfill: true
    },
    svg: {
      paths: ['public']
    }
  });

  app.import('node_modules/spin.js/spin.js');
  app.import('node_modules/diff/dist/diff.js');

  return app.toTree();
};
