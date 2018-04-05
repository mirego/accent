/* eslint-env node */
/* eslint-env es6:false */
/* eslint no-undef:0 */

module.exports = {
  'framework': 'mocha',
  'test_page': 'tests/index.html?hidepassed',
  'disable_watching': true,
  'launch_in_ci': [
    'PhantomJS'
  ],
  'launch_in_dev': [
    'PhantomJS',
    'Chrome',
    'Firefox'
  ]
};
