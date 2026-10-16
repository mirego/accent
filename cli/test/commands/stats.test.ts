import assert from 'node:assert/strict';
import {describe, it} from 'node:test';
import {buildProject, buildRevision} from '../support/factory';
import {PROJECT_ID, setup} from '../support/setup';

const files = [
  {format: 'json', source: 'en/*.json', target: '%slug%/%document_path%.json'}
];

const project = buildProject({
  name: 'Accent app',
  revisions: [
    buildRevision('en', {
      isMaster: true,
      name: 'English',
      translationsCount: 10,
      reviewedCount: 10,
      translatedCount: 10
    }),
    buildRevision('fr', {
      translationsCount: 10,
      reviewedCount: 6,
      translatedCount: 8,
      conflictsCount: 4
    })
  ],
  documents: {
    entries: [
      {path: 'app', format: 'json'},
      {path: 'legacy', format: 'gettext'}
    ],
    meta: {totalEntries: 2}
  },
  versions: {
    entries: [
      {tag: 'v1', name: 'v1'},
      {tag: 'v2', name: 'v2'}
    ],
    meta: {totalEntries: 2}
  },
  collaborators: [
    {
      id: '1',
      role: 'OWNER',
      user: {email: 'owner@example.com', fullname: 'Owner Name'}
    },
    {
      id: '2',
      role: 'OWNER',
      user: {email: 'solo@example.com', fullname: 'solo@example.com'}
    },
    {
      id: '3',
      role: 'REVIEWER',
      user: {email: 'reviewer@example.com', fullname: 'Reviewer'}
    }
  ]
});

const completeProject = buildProject();

describe('stats', () => {
  it('displays the project stats', async () => {
    const {server, workspace, config} = await setup({project});
    workspace.writeConfig(config({files}));
    workspace.write('en/app.json', {});

    const result = await workspace.run(['stats']);

    assert.equal(result.code, 0, result.output);
    assert.match(result.stdout, /Accent app • 80% reviewed/);
    assert.match(result.stdout, /Last synced\s+2026-01-01T00:00:00Z/);
    assert.match(
      result.stdout,
      new RegExp(`URL\\s+${server.url}/app/projects/${PROJECT_ID}`)
    );
    assert.match(
      result.stdout,
      /Languages \(2\)\n\s+English \(en\)\s+main language\n\s+FR \(fr\)\s+60% reviewed/
    );
    assert.match(result.stdout, /Documents \(2\)/);
    assert.match(result.stdout, /✓ app\s+en\/app\.json/);
    assert.match(result.stdout, /• legacy\s+gettext, no match in config file/);
    assert.match(result.stdout, /Versions \(2\)\n\s+v1\n\s+v2/);
    assert.match(result.stdout, /Strings \(20\)/);
    assert.match(result.stdout, /✓ Reviewed\s+16/);
    assert.match(result.stdout, /✗ In review\s+4/);
    assert.match(result.stdout, /✎ Translated\s+18/);
    assert.match(
      result.stdout,
      /Owners \(2\)\n\s+Owner Name owner@example\.com\n\s+solo@example\.com\n/
    );
    assert.doesNotMatch(result.stdout, /reviewer@example\.com/);
    assert.doesNotMatch(result.stdout, /Version\s/);
    assert.equal(server.requestsTo('POST /graphql').length, 1);
  });

  it('displays a project without strings', async () => {
    const empty = buildProject({
      lastSyncedAt: '',
      revisions: [
        buildRevision('en', {
          isMaster: true,
          translationsCount: 0,
          reviewedCount: 0,
          translatedCount: 0
        })
      ]
    });
    const {workspace, config} = await setup({project: empty});
    workspace.writeConfig(config({files}));

    const result = await workspace.run(['stats']);

    assert.equal(result.code, 0, result.output);
    assert.match(result.stdout, /My project • No strings/);
    assert.match(result.stdout, /Last synced\s+Never synced/);
    assert.match(result.stdout, /Strings \(0\)\n\s+No strings/);
    assert.doesNotMatch(result.stdout, /Documents|Versions|Owners/);
  });

  it('fetches the stats of --version', async () => {
    const {server, workspace, config} = await setup({project});
    workspace.writeConfig(config({files}));

    const result = await workspace.run(['stats', '--version=v2']);

    assert.equal(result.code, 0, result.output);
    const requests = server.requestsTo('POST /graphql');
    assert.equal(requests.length, 2);
    assert.deepEqual(requests[0].json.variables, {project_id: PROJECT_ID});
    assert.deepEqual(requests[1].json.variables, {
      project_id: PROJECT_ID,
      versionId: 'v2'
    });
    assert.match(result.stdout, /Version\s+v2/);
    assert.match(result.stdout, /Versions \(2\)\n\s+v1\n\s+→ v2/);
  });

  it('uses the version from the git branch', async () => {
    const {server, workspace, config} = await setup({project});
    workspace.gitInit('release/v1');
    workspace.writeConfig(
      config({files, version: {branchVersionPrefix: 'release/'}})
    );

    const result = await workspace.run(['stats']);

    assert.equal(result.code, 0, result.output);
    assert.equal(
      server.requestsTo('POST /graphql')[1].json.variables.versionId,
      'v1'
    );
    assert.match(result.stdout, /Git branch\s+release\/v1/);
    assert.match(result.stdout, /Version\s+v1/);
  });

  it('ignores git branches without the version prefix', async () => {
    const {server, workspace, config} = await setup({project});
    workspace.gitInit('main');
    workspace.writeConfig(
      config({files, version: {branchVersionPrefix: 'release/'}})
    );

    const result = await workspace.run(['stats']);

    assert.equal(result.code, 0, result.output);
    assert.equal(server.requestsTo('POST /graphql').length, 1);
    assert.match(result.stdout, /Git branch\s+main/);
  });

  it('prefers --version over the git branch version', async () => {
    const {server, workspace, config} = await setup({project});
    workspace.gitInit('release/v1');
    workspace.writeConfig(
      config({files, version: {branchVersionPrefix: 'release/'}})
    );

    const result = await workspace.run(['stats', '--version=v2']);

    assert.equal(result.code, 0, result.output);
    assert.equal(
      server.requestsTo('POST /graphql')[1].json.variables.versionId,
      'v2'
    );
  });

  describe('--check-reviewed', () => {
    it('fails when strings are in review', async () => {
      const {workspace, config} = await setup({project});
      workspace.writeConfig(config({files}));

      const result = await workspace.run(['stats', '--check-reviewed']);

      assert.equal(result.code, 1);
      assert.match(result.stderr, /Project has 4 strings to be reviewed/);
    });

    it('includes the version in the error', async () => {
      const {workspace, config} = await setup({project});
      workspace.writeConfig(config({files}));

      const result = await workspace.run([
        'stats',
        '--check-reviewed',
        '--version=v1'
      ]);

      assert.equal(result.code, 1);
      assert.match(result.stderr, /Project v1 has 4 strings to be reviewed/);
    });

    it('succeeds when all strings are reviewed', async () => {
      const {workspace, config} = await setup({project: completeProject});
      workspace.writeConfig(config({files}));

      const result = await workspace.run(['stats', '--check-reviewed']);

      assert.equal(result.code, 0, result.output);
    });
  });

  describe('--check-translated', () => {
    it('fails when strings are not translated', async () => {
      const {workspace, config} = await setup({project});
      workspace.writeConfig(config({files}));

      const result = await workspace.run(['stats', '--check-translated']);

      assert.equal(result.code, 1);
      assert.match(result.stderr, /Project has 2 strings to be translated/);
    });

    it('succeeds when all strings are translated', async () => {
      const {workspace, config} = await setup({project: completeProject});
      workspace.writeConfig(config({files}));

      const result = await workspace.run(['stats', '--check-translated']);

      assert.equal(result.code, 0, result.output);
    });
  });
});
