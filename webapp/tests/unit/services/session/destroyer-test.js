import EmberObject from '@ember/object';
import { expect } from 'chai';
import {
  describeModule,
  it,
  beforeEach,
  afterEach
} from 'ember-mocha';
import config from 'accent-webapp/config/environment';

describeModule(
  'service:session/destroyer',
  'service:session/destroyer',
  {
    needs: []
  },
  () => {
    let service;

    const credentials = {
      user: {email: 'test@mirego.com'},
      token: 'abc123'
    };

    const sessionStub = EmberObject.extend({
      credentials: {
        user: {email: 'test@mirego.com'},
        token: 'abc123'
      }
    });

    beforeEach(() => {
      service = this.subject({session: sessionStub.create()});

      // Fake a previous login
      localStorage.setItem(config.APP.LOCAL_STORAGE.SESSION_NAMESPACE, service.get('session.credentials'));

      expect(service.get('session.credentials')).to.deep.equal(credentials);
    });

    afterEach(() => {
      localStorage.removeItem(config.APP.LOCAL_STORAGE.SESSION_NAMESPACE);
    });

    it('should nullify the session’s credentials', () => {
      service.destroySession();

      expect(service.get('session.credentials')).to.be.null;
    });

    it('should remove the credentials from localStorage', () => {
      service.destroySession();

      expect(localStorage.getItem(config.APP.LOCAL_STORAGE.SESSION_NAMESPACE)).to.be.null;
    });
  }
);
