/* eslint-env node */

'use strict';

const EmberApp = require('ember-cli/lib/broccoli/ember-app');

module.exports = function(defaults) {
  const app = new EmberApp(defaults, {
    hinting: false,
    componentStructure: 'nested',

    vendorFiles: {
      'jquery.js': null,
    },

    babel: {
      plugins: [require('ember-auto-import/babel-plugin'), require.resolve("ember-concurrency/async-arrow-task-transform")],
      sourceMaps: 'inline',
    },

    'ember-cli-babel': { enableTypeScriptTransform: true },

    svg: {
      paths: ['public'],
    },

    'ember-scoped-css': {
      layerName: false,
    },
  });

  app.import('node_modules/diff/dist/diff.js');

  return app.toTree();
};
