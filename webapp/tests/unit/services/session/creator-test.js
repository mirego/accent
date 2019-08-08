import {expect} from 'chai';
import {describe, it, beforeEach, afterEach} from 'mocha';
import {setupTest} from 'ember-mocha';
import sinon from 'sinon';

import config from 'accent-webapp/config/environment';

const HTTP_STATUS = {
  ok: 200
};

describe('Unit | Services | Session | creator', () => {
  setupTest('service:session/creator');

  let server;
  let service;

  beforeEach(function() {
    server = sinon.createFakeServer();
    server.autoRespond = true;
    server.respondImmediately = true;

    service = this.subject();
  });

  afterEach(() => {
    server.restore();
  });

  it('should return a promise', async () => {
    server.respondWith(config.API.AUTHENTICATION_PATH, [
      HTTP_STATUS.ok,
      {'Content-Type': 'application/json'},
      ''
    ]);

    const result = service.createSession({username: 'test@mirego.com'});

    expect(result).to.respondTo('then');

    await result;
  });

  it('should resolve with the credentials returned from the API', async () => {
    const credentialsJSON =
      '{"user":{"email":"test@mirego.com"},"token":"abc123"}';

    server.respondWith(config.API.AUTHENTICATION_PATH, [
      HTTP_STATUS.ok,
      {'Content-Type': 'application/json'},
      credentialsJSON
    ]);

    const credentials = await service.createSession({
      username: 'test@mirego.com'
    });

    expect(credentials).to.deep.equal(JSON.parse(credentialsJSON));
  });
});
