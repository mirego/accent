import { expect } from 'chai';
import {
  describeModule,
  it,
  beforeEach,
  afterEach
} from 'ember-mocha';
import config from 'accent-webapp/config/environment';

describeModule(
  'service:session/persister',
  'service:session/persister',
  {
    needs: []
  },
  () => {
    let service;
    const credentials = {
      user: {email: 'test@mirego.com'},
      token: 'abc123'
    };

    beforeEach(() => {
      service = this.subject();
    });

    afterEach(() => {
      localStorage.removeItem(config.APP.LOCAL_STORAGE.SESSION_NAMESPACE);
    });

    it('should persist the session credentials to localStorage', () => {
      service.persist(credentials);

      expect(localStorage.getItem(config.APP.LOCAL_STORAGE.SESSION_NAMESPACE)).to.equal(JSON.stringify(credentials));
    });
  }
);
