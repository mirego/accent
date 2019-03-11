import {expect} from 'chai';
import {describe, it, beforeEach, afterEach} from 'mocha';
import {setupTest} from 'ember-mocha';

import config from 'accent-webapp/config/environment';

describe('Unit | Services | Session | fetcher', () => {
  setupTest('service:session/fetcher');

  let service;

  const credentials = {
    user: {email: 'test@mirego.com'},
    token: 'abc123'
  };

  beforeEach(function() {
    service = this.subject();

    // Fake a previous login
    localStorage.setItem(
      config.APP.LOCAL_STORAGE.SESSION_NAMESPACE,
      JSON.stringify(credentials)
    );
  });

  afterEach(() => {
    localStorage.removeItem(config.APP.LOCAL_STORAGE.SESSION_NAMESPACE);
  });

  it('should read the session credentials from localStorage', () => {
    expect(service.fetch()).to.deep.equal(credentials);
  });
});
