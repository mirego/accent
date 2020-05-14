// Vendor
import {describe, it, beforeEach, afterEach} from 'mocha';
import {expect} from 'chai';
import {setupApplicationTest} from 'ember-mocha';
import {visit, waitFor, typeIn, click} from '@ember/test-helpers';
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
  fakeConfirmedCollaborator,
  fakePendingCollaborator,
  fakeProject,
  fakeUser,
} from 'accent-webapp/tests/helpers/graphql-fixtures';
import delay from 'accent-webapp/tests/helpers/delay';

describe('Acceptance | Logged in | Project | Collaborators page', function () {
  setupApplicationTest();
  setupIntl(this, 'en-ca');

  let server: Server;
  let project: object;

  beforeEach(function () {
    server = setupPretender();
    loginFakeUser();

    project = fakeProject({
      id: 'fake-project',
    });

    server.query('Project', () => ({
      documentFormats: [],
      roles: [
        {
          __typename: 'RoleItem',
          slug: 'OWNER',
        },
        {
          __typename: 'RoleItem',
          slug: 'ADMIN',
        },
        {
          __typename: 'RoleItem',
          slug: 'DEVELOPER',
        },
        {
          __typename: 'RoleItem',
          slug: 'REVIEWER',
        },
      ],
      viewer: {
        __typename: 'Viewer',
        project,
      },
    }));
  });

  afterEach(function () {
    logoutFakeUser();
  });

  it('should list the current collaborators', async function () {
    server.query('ProjectCollaborators', () => ({
      viewer: {
        __typename: 'Viewer',
        project: {
          ...project,
          collaborators: [
            fakeConfirmedCollaborator({
              role: 'OWNER',
              email: 'bbanner@mirego.com',
              user: fakeUser({
                fullname: 'Bruce Banner',
              }),
            }),
          ],
        },
      },
    }));

    await visit('/app/projects/fake-project/edit/collaborators');

    expect('[data-test-loader]').to.be.rendered;

    await waitFor('[data-test-collaborators-list]');

    expect('[data-test-loader]').to.be.not.rendered;
    expect('[data-test-collaborator]').to.have.count(1);
    expect('[data-test-collaborator-fullname]').to.have.textContent(
      'Bruce Banner'
    );
    expect('[data-test-collaborator-email]').to.have.textContent(
      'bbanner@mirego.com'
    );
  });

  it('should support inviting a collaborator', async function () {
    server.query('ProjectCollaborators', ({calls}) => ({
      viewer: {
        __typename: 'Viewer',
        project: {
          ...project,
          collaborators: [
            fakeConfirmedCollaborator({
              role: 'OWNER',
              email: 'bbanner@mirego.com',
              user: fakeUser({
                fullname: 'Bruce Banner',
              }),
            }),
            calls === 2
              ? fakePendingCollaborator({
                  email: 'pparker@mirego.com',
                })
              : null,
          ].filter(Boolean),
        },
      },
    }));

    server.mutation('CollaboratorCreate', {
      response: () => ({
        createCollaborator: {
          __typename: 'MutatedCollaborator',
          collaborator: {
            __typename: 'PendingCollaborator',
            id: 'random-collaborator-id',
          },
          errors: null,
        },
      }),
      expects: ({variables}) => {
        expect(variables!.projectId).to.equal('fake-project');
        expect(variables!.email).to.be.equal('pparker@mirego.com');
        expect(variables!.role).to.be.equal('OWNER');
      },
    });

    await visit('/app/projects/fake-project/edit/collaborators');
    await waitFor('[data-test-collaborators-list]');

    expect('[data-test-collaborator]').to.have.count(1);
    expect(
      '[data-test-collaborator]:first-child [data-test-collaborator-email]'
    ).to.have.textContent('bbanner@mirego.com');

    await click('[data-test-new-collaborator-init]');
    await typeIn('[data-test-new-collaborator-email]', 'pparker@mirego.com');
    await click('[data-test-new-collaborator-submit]');

    // Wait for Apollo refetchQueries
    await delay(500);

    expect('[data-test-collaborator]').to.have.count(2);
    expect(
      '[data-test-collaborator]:first-child [data-test-collaborator-email]'
    ).to.have.textContent('bbanner@mirego.com');
    expect(
      '[data-test-collaborator]:last-child [data-test-collaborator-email]'
    ).to.have.textContent('pparker@mirego.com');
  });

  it('should support removing a collaborator', async function () {
    server.query('ProjectCollaborators', ({calls}) => ({
      viewer: {
        __typename: 'Viewer',
        project: {
          ...project,
          collaborators: [
            calls === 1
              ? fakeConfirmedCollaborator({
                  id: 'the-collaborator-id',
                  role: 'OWNER',
                  email: 'bbanner@mirego.com',
                  user: fakeUser({
                    fullname: 'Bruce Banner',
                  }),
                })
              : null,
          ].filter(Boolean),
        },
      },
    }));

    server.mutation('CollaboratorDelete', {
      response: () => ({
        deleteCollaborator: {
          __typename: 'MutatedCollaborator',
          collaborator: {
            __typename: 'ConfirmedCollaborator',
            id: 'random-collaborator-id',
          },
          errors: null,
        },
      }),
      expects: ({variables}) => {
        expect(variables!.collaboratorId).to.equal('the-collaborator-iid');
      },
    });

    await visit('/app/projects/fake-project/edit/collaborators');
    await waitFor('[data-test-collaborators-list]');

    expect('[data-test-collaborator]').to.have.count(1);

    await click('[data-test-collaborator-remove]');

    // Wait for Apollo refetchQueries
    await delay(500);

    expect('[data-test-collaborator]').to.have.count(0);
  });
});
