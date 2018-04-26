/* eslint-env node */
/* eslint-disable camelcase */

'use strict';

module.exports = {
  test_page: 'tests/index.html?hidepassed',
  disable_watching: true,
  launch_in_ci: ['Chrome'],
  launch_in_dev: ['Chrome'],
  browser_args: {
    Chrome: [
      // --no-sandbox is needed when running Chrome inside a container
      process.env.TRAVIS ? '--no-sandbox' : null,
      '--headless',
      '--disable-gpu',
      '--remote-debugging-port=9222'
    ].filter(Boolean)
  }
};
