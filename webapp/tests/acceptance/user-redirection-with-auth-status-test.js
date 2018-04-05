import { run } from '@ember/runloop';
import {
  describe,
  it,
  beforeEach,
  afterEach,
  currentPath,
  andThen,
  visit
} from 'mocha';
import { expect } from 'chai';
import startApp from '../helpers/start-app';
import config from 'accent-webapp/config/environment';

describe('User redirection with auth status', () => {
  let application;

  beforeEach(() => {
    application = startApp();
  });

  afterEach(() => {
    run(application, 'destroy');
  });

  describe('Not logged', () => {
    it('should be redirected to the login page if they access /', () => {
      visit('/');

      andThen(() => {
        expect(currentPath()).to.equal('login');
      });
    });

    it('should be able to access the login page', () => {
      visit('login');

      andThen(() => {
        expect(currentPath()).to.equal('login');
      });
    });

    it('should not be able to access the logged-in section', () => {
      visit('app');

      andThen(() => {
        expect(currentPath()).to.equal('login');
      });
    });
  });

  describe('Logged in', () => {
    beforeEach(() => {
      const credentials = {
        user: {email: 'test@mirego.com'},
        token: 'abc123'
      };

      localStorage.setItem(config.APP.LOCAL_STORAGE.SESSION_NAMESPACE, JSON.stringify(credentials));
    });

    afterEach(() => {
      localStorage.removeItem(config.APP.LOCAL_STORAGE.SESSION_NAMESPACE);
    });

    it('should be redirected to the projects page if they access /', () => {
      visit('/');

      andThen(() => {
        expect(currentPath()).to.equal('logged-in.projects');
      });
    });

    it('should be redirected to the projects page if they access the login page', () => {
      visit('login');

      andThen(() => {
        expect(currentPath()).to.equal('logged-in.projects');
      });
    });

    it('should be able to access the projects page', () => {
      visit('app/projects');

      andThen(() => {
        expect(currentPath()).to.equal('logged-in.projects');
      });
    });
  });
});
