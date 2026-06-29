/* eslint-env node */

'use strict';

const EmberApp = require('ember-cli/lib/broccoli/ember-app');
const {compatBuild} = require('@embroider/compat');

module.exports = async function(defaults) {
  const {buildOnce} = await import('@embroider/vite');

  const app = new EmberApp(defaults, {
    hinting: false,
    componentStructure: 'nested',

    vendorFiles: {
      'jquery.js': null,
    },

    babel: {sourceMaps: 'inline'},

    'ember-cli-babel': {enableTypeScriptTransform: true},

    ':global(svg)': {
      paths: ['public'],
    },

    'ember-scoped-css': {
      layerName: false,
    },
  });

  return compatBuild(app, buildOnce);
};
