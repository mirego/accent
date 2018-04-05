/* eslint-env node */
/* eslint-env es6:false */
/* eslint no-var:0 */

var EmberApp = require('ember-cli/lib/broccoli/ember-app');

module.exports = function(defaults) {
  var app = new EmberApp(defaults, {
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
    },
    nodeAssets: {
      diff: {
        srcDir: 'dist',
        vendor: ['diff.js'],
        import: ['diff.js']
      },
      'spin.js': {
        srcDir: '',
        vendor: ['spin.js'],
        import: ['spin.js']
      }
    }
  });

  return app.toTree();
};
