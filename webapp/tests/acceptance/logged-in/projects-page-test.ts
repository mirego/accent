// Vendor
import {describe, it, beforeEach, afterEach} from 'mocha';
import {expect} from 'chai';
import {setupApplicationTest} from 'ember-mocha';
import {visit, waitFor} from '@ember/test-helpers';
import {setupIntl} from 'ember-intl/test-support';

// Helpers
import {
  setupPretender,
  Server,
} from 'accent-webapp/tests/helpers/pretender-setup';
import {
  loginFakeUser,
  logoutFakeUser,
} from 'accent-webapp/tests/helpers/fake-user';
import {
  fakeLanguage,
  fakeProject,
} from 'accent-webapp/tests/helpers/graphql-fixtures';

describe('Acceptance | Logged in | Projects page', function () {
  setupApplicationTest();
  setupIntl(this, 'en-ca');

  let server: Server;

  beforeEach(function () {
    server = setupPretender();
    loginFakeUser();
  });

  afterEach(function () {
    logoutFakeUser();
  });

  describe('with actives projects', function () {
    beforeEach(function () {
      server.query('Projects', () => ({
        languages: {
          __typename: 'Languages',
          entries: [fakeLanguage(), fakeLanguage()],
        },
        viewer: {
          __typename: 'Viewer',
          permissions: [
            'create_project',
            'index_permissions',
            'index_projects',
          ],
          projects: {
            __typename: 'Projects',
            entries: [
              fakeProject({name: 'First project'}),
              fakeProject({name: 'Second project'}),
            ],
            meta: {
              __typename: 'PaginationMeta',
              currentPage: 1,
              nextPage: null,
              previousPage: null,
              totalEntries: 2,
              totalPages: 1,
            },
          },
        },
      }));
    });

    it('should display the projects', async function () {
      await visit('/app/projects');

      expect('[data-test-loader]').to.be.rendered;

      await waitFor('[data-test-projects-list]');

      expect('[data-test-loader]').to.be.not.rendered;
      expect('[data-test-empty-content]').to.be.not.rendered;
      expect('[data-test-project]').to.have.count(2);
      expect(
        '[data-test-project="0"] [data-test-project-name]'
      ).to.have.textContent('First project');
      expect(
        '[data-test-project="1"] [data-test-project-name]'
      ).to.have.textContent('Second project');
    });
  });

  describe('with no active project', function () {
    beforeEach(function () {
      server.query('Projects', () => ({
        languages: {
          __typename: 'Languages',
          entries: [fakeLanguage(), fakeLanguage()],
        },
        viewer: {
          __typename: 'Viewer',
          permissions: [
            'create_project',
            'index_permissions',
            'index_projects',
          ],
          projects: {
            __typename: 'Projects',
            entries: [],
            meta: {
              __typename: 'PaginationMeta',
              currentPage: 1,
              nextPage: null,
              previousPage: null,
              totalEntries: 0,
              totalPages: 1,
            },
          },
        },
      }));
    });

    it('should display a no-content placeholder', async function () {
      await visit('/app/projects');

      expect('[data-test-loader]').to.be.rendered;

      await waitFor('[data-test-projects-list]');

      expect('[data-test-loader]').to.be.not.rendered;
      expect('[data-test-empty-content]').to.be.rendered;
    });
  });
});
