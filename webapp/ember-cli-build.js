/* eslint-env node */

'use strict';

const EmberApp = require('ember-cli/lib/broccoli/ember-app');
const target = require('./config/targets');
const sass = require('sass');

module.exports = function (defaults) {
  const app = new EmberApp(defaults, {
    hinting: false,

    vendorFiles: {
      'jquery.js': null,
    },

    autoprefixer: {
      browsers: target.browsers,
    },

    autoImport: {
      exclude: ['graphql-tag'],
    },

    babel: {
      plugins: ['graphql-tag', require('ember-auto-import/babel-plugin')],
      sourceMaps: 'inline',
    },

    'ember-cli-babel-polyfills': {
      evergreenTargets: target.browsers,
    },

    svg: {
      paths: ['public'],
    },

    sassOptions: {
      implementation: sass,
    },
  });

  app.import('node_modules/diff/dist/diff.js');

  return app.toTree();
};
