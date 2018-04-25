/* eslint-env node */

const EmberApp = require('ember-cli/lib/broccoli/ember-app');

module.exports = function(defaults) {
  const app = new EmberApp(defaults, {
    hinting: false,
    vendorFiles: {
      'jquery.js': null,
    },
    autoprefixer: {
      browsers: [
        'ie >= 10',
        'last 2 versions'
      ]
    },
    babel: {
      sourceMaps: 'inline',
      plugins: ['transform-object-rest-spread']
    },
    'ember-cli-babel': {
      includePolyfill: true
    },
    svg: {
      paths: [
        'public'
      ]
    }
  });

  app.import('node_modules/spin.js/spin.js');
  app.import('node_modules/diff/dist/diff.js');

  return app.toTree();
};
