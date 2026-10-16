import assert from 'node:assert/strict';
import {describe, it} from 'node:test';
import {buildProject, buildRevision} from '../support/factory';
import {RecordedRequest} from '../support/server';
import {API_KEY, PROJECT_ID, setup} from '../support/setup';

const toRoute = ({method, path}: RecordedRequest) => `${method} ${path}`;
const toDocumentPath = ({form}: RecordedRequest) => form!.document_path;

const files = [
  {format: 'json', source: 'en/*.json', target: '%slug%/%document_path%.json'}
];

const peekResponse = {
  data: {
    operations: {
      'revision-en': [
        {action: 'new', key: 'greeting', text: 'Hello', 'previous-text': null},
        {
          action: 'conflict_on_proposed',
          key: 'title',
          text: 'Title',
          'previous-text': 'Old title'
        },
        {
          action: 'remove',
          key: 'unused',
          text: null,
          'previous-text': 'Unused'
        }
      ],
      'revision-fr': [
        {action: 'new', key: 'greeting', text: 'Hello', 'previous-text': null},
        {
          action: 'conflict_on_corrected',
          key: 'title',
          text: 'Title',
          'previous-text': 'Titre'
        }
      ]
    },
    stats: {
      'revision-en': {new: 1, conflict_on_proposed: 1, remove: 1},
      'revision-fr': {new: 1, conflict_on_corrected: 1}
    }
  }
};

describe('sync', () => {
  it('syncs the main language files then writes every language locally', async () => {
    const {server, workspace, config} = await setup();
    workspace.writeConfig(config({files}));
    workspace.write('en/app.json', '{"key":"value"}');
    workspace.write('en/errors.json', '{"error":"Error"}');

    const result = await workspace.run(['sync']);

    assert.equal(result.code, 0, result.output);

    const syncs = server
      .requestsTo('POST /sync')
      .sort((a, b) =>
        String(a.form!.document_path).localeCompare(
          String(b.form!.document_path)
        )
      );
    assert.equal(syncs.length, 2);
    assert.equal(syncs[0].headers.authorization, `Bearer ${API_KEY}`);
    assert.deepEqual(syncs[0].form, {
      file: {filename: 'app.json', content: '{"key":"value"}'},
      document_path: 'app',
      document_format: 'json',
      language: 'en',
      project_id: PROJECT_ID,
      sync_type: 'smart'
    });
    assert.equal(syncs[1].form!.document_path, 'errors');

    assert.equal(server.requestsTo('POST /graphql').length, 2);
    assert.equal(server.requestsTo('GET /export').length, 4);
    assert.equal(server.requestsTo('POST /sync/peek').length, 0);
    assert.equal(server.requestsTo('POST /add-translations').length, 0);

    assert.deepEqual(JSON.parse(workspace.read('en/app.json')), {
      exported: 'en:app'
    });
    assert.deepEqual(JSON.parse(workspace.read('fr/errors.json')), {
      exported: 'fr:errors'
    });

    assert.match(result.stdout, /Syncing sources → en\n/);
    assert.match(result.stdout, /↑ en\/app\.json app/);
    assert.match(result.stdout, /Writing files locally/);
    assert.match(result.stdout, /↓ fr\/app\.json app → fr/);
    assert.match(result.stdout, /✓ Sync completed in/);
  });

  it('syncs with the main revision slug', async () => {
    const project = buildProject({
      revisions: [
        buildRevision('en', {isMaster: true, slug: 'en-US'}),
        buildRevision('fr')
      ]
    });
    const {server, workspace, config} = await setup({project});
    workspace.writeConfig(config({files}));
    workspace.write('en/app.json', '{}');

    const result = await workspace.run(['sync', '--no-local-write']);

    assert.equal(result.code, 0, result.output);
    assert.equal(server.requestsTo('POST /sync')[0].form!.language, 'en-US');
    assert.match(result.stdout, /Syncing sources → en-US/);
  });

  it('exports the languages of the project refreshed after the sync', async () => {
    let calls = 0;
    const {server, workspace, config} = await setup({
      project: () => {
        calls++;
        return calls === 1
          ? buildProject({revisions: [buildRevision('en', {isMaster: true})]})
          : buildProject();
      }
    });
    workspace.writeConfig(config({files}));
    workspace.write('en/app.json', '{}');

    const result = await workspace.run(['sync']);

    assert.equal(result.code, 0, result.output);
    assert.deepEqual(
      server.requestsTo('GET /export').map(({query}) => query.language),
      ['en', 'fr']
    );
  });

  it('sends --sync-type', async () => {
    const {server, workspace, config} = await setup();
    workspace.writeConfig(config({files}));
    workspace.write('en/app.json', '{}');

    const result = await workspace.run(['sync', '--sync-type=passive']);

    assert.equal(result.code, 0, result.output);
    assert.equal(server.requestsTo('POST /sync')[0].form!.sync_type, 'passive');
  });

  it('rejects an invalid --sync-type', async () => {
    const {server, workspace, config} = await setup();
    workspace.writeConfig(config({files}));
    workspace.write('en/app.json', '{}');

    const result = await workspace.run(['sync', '--sync-type=force']);

    assert.notEqual(result.code, 0);
    assert.match(
      result.stderr,
      /Expected --sync-type=force to be one of: smart, passive/
    );
    assert.equal(server.requestsTo('POST /sync').length, 0);
  });

  it('sends --version to the sync and the export', async () => {
    const {server, workspace, config} = await setup();
    workspace.writeConfig(config({files}));
    workspace.write('en/app.json', '{}');

    const result = await workspace.run(['sync', '--version=v1.0']);

    assert.equal(result.code, 0, result.output);
    assert.equal(server.requestsTo('POST /sync')[0].form!.version, 'v1.0');
    for (const {query} of server.requestsTo('GET /export')) {
      assert.equal(query.version, 'v1.0');
    }
    assert.match(result.stdout, /Syncing sources → en @ v1\.0/);
  });

  it('sends the version and the branch from git', async () => {
    const {server, workspace, config} = await setup();
    workspace.gitInit('release/v2.0');
    workspace.writeConfig(
      config({files, version: {branchVersionPrefix: 'release/'}})
    );
    workspace.write('en/app.json', '{}');

    const result = await workspace.run(['sync']);

    assert.equal(result.code, 0, result.output);
    const [sync] = server.requestsTo('POST /sync');
    assert.equal(sync.form!.version, 'v2.0');
    assert.equal(sync.form!.git_branch, 'release/v2.0');
    for (const {query} of server.requestsTo('GET /export')) {
      assert.equal(query.version, 'v2.0');
    }
  });

  it('prefers --version over the git branch version', async () => {
    const {server, workspace, config} = await setup();
    workspace.gitInit('release/v2.0');
    workspace.writeConfig(
      config({files, version: {branchVersionPrefix: 'release/'}})
    );
    workspace.write('en/app.json', '{}');

    const result = await workspace.run(['sync', '--version=v3.0']);

    assert.equal(result.code, 0, result.output);
    assert.equal(server.requestsTo('POST /sync')[0].form!.version, 'v3.0');
  });

  it('does not send a version or branch outside of a git repository', async () => {
    const {server, workspace, config} = await setup();
    workspace.writeConfig(
      config({files, version: {branchVersionPrefix: 'release/'}})
    );
    workspace.write('en/app.json', '{}');

    const result = await workspace.run(['sync']);

    assert.equal(result.code, 0, result.output);
    const [sync] = server.requestsTo('POST /sync');
    assert.equal(sync.form!.version, undefined);
    assert.equal(sync.form!.git_branch, undefined);
  });

  it('does not write local files with --no-local-write', async () => {
    const {server, workspace, config} = await setup();
    workspace.writeConfig(config({files}));
    workspace.write('en/app.json', '{"key":"value"}');

    const result = await workspace.run(['sync', '--no-local-write']);

    assert.equal(result.code, 0, result.output);
    assert.equal(server.requestsTo('POST /sync').length, 1);
    assert.equal(server.requestsTo('GET /export').length, 0);
    assert.equal(workspace.read('en/app.json'), '{"key":"value"}');
    assert.ok(!workspace.exists('fr/app.json'));
    assert.doesNotMatch(result.stdout, /Writing files locally/);
  });

  it('fails with the server error message', async () => {
    const {server, workspace, config} = await setup({
      routes: {'POST /sync': () => ({status: 422, body: 'Unsupported format'})}
    });
    workspace.writeConfig(config({files}));
    workspace.write('en/app.json', '{"key":"value"}');

    const result = await workspace.run(['sync']);

    assert.equal(result.code, 1);
    assert.match(result.stderr, /Unsupported format/);
    assert.equal(server.requestsTo('GET /export').length, 0);
    assert.equal(workspace.read('en/app.json'), '{"key":"value"}');
  });

  describe('--dry-run', () => {
    it('peeks the sync without committing nor writing files', async () => {
      const {server, workspace, config} = await setup({
        routes: {'POST /sync/peek': () => ({body: peekResponse})}
      });
      workspace.writeConfig(config({files}));
      workspace.write('en/app.json', '{"key":"value"}');

      const result = await workspace.run(['sync', '--dry-run']);

      assert.equal(result.code, 0, result.output);

      const [peek] = server.requestsTo('POST /sync/peek');
      assert.deepEqual(peek.form, {
        file: {filename: 'app.json', content: '{"key":"value"}'},
        document_path: 'app',
        document_format: 'json',
        language: 'en',
        project_id: PROJECT_ID,
        sync_type: 'smart'
      });
      assert.equal(server.requestsTo('POST /sync').length, 0);
      assert.equal(server.requestsTo('GET /export').length, 0);
      assert.equal(server.requestsTo('POST /graphql').length, 1);
      assert.equal(workspace.read('en/app.json'), '{"key":"value"}');

      assert.match(result.stdout, /Syncing sources → en \(dry run\)/);
      assert.match(result.stdout, /• en\/app\.json app\n/);
      assert.match(result.stdout, /New\s+1\n/);
      assert.match(result.stdout, /Conflict on proposed\s+1\n/);
      assert.match(result.stdout, /Remove\s+1\n/);
      assert.match(result.stdout, /Conflict on corrected\s+1\n/);
      assert.match(result.stdout, /✓ Dry run completed in/);
      assert.match(result.stdout, /Remove --dry-run to commit changes/);
    });

    it('displays no changes', async () => {
      const {workspace, config} = await setup();
      workspace.writeConfig(config({files}));
      workspace.write('en/app.json', '{}');

      const result = await workspace.run(['sync', '--dry-run']);

      assert.equal(result.code, 0, result.output);
      assert.match(result.stdout, /• en\/app\.json app\n\s+No changes/);
    });

    it('displays every operation with --details', async () => {
      const {workspace, config} = await setup({
        routes: {'POST /sync/peek': () => ({body: peekResponse})}
      });
      workspace.writeConfig(config({files}));
      workspace.write('en/app.json', '{}');

      const result = await workspace.run(['sync', '--dry-run', '--details']);

      assert.equal(result.code, 0, result.output);
      assert.match(
        result.stdout,
        /Conflict on corrected \(1\)\n\s+\[fr\] title\n\s+- "Titre"\n\s+\+ "Title"/
      );
      assert.match(
        result.stdout,
        /Conflict on proposed \(1\)\n\s+\[en\] title\n\s+- "Old title"\n\s+\+ "Title"/
      );
      assert.match(
        result.stdout,
        /New \(1\)\n\s+\[en\] greeting\n\s+\+ "Hello"\n/
      );
      assert.match(
        result.stdout,
        /Remove \(1\)\n\s+\[en\] unused\n\s+- "Unused"\n/
      );
      assert.doesNotMatch(result.stdout, /\[fr\] greeting/);
    });

    it('requires --dry-run for --details', async () => {
      const {server, workspace, config} = await setup();
      workspace.writeConfig(config({files}));
      workspace.write('en/app.json', '{}');

      const result = await workspace.run(['sync', '--details']);

      assert.notEqual(result.code, 0);
      assert.match(
        result.stderr,
        /must be provided when using --details: --dry-run/
      );
      assert.equal(server.requestsTo('POST /sync').length, 0);
    });
  });

  describe('--add-translations', () => {
    it('adds the local translations of the other languages', async () => {
      const {server, workspace, config} = await setup();
      workspace.writeConfig(config({files}));
      workspace.write('en/app.json', '{"key":"value"}');
      workspace.write('fr/app.json', '{"key":"valeur"}');

      const result = await workspace.run([
        'sync',
        '--add-translations',
        '--merge-type=smart'
      ]);

      assert.equal(result.code, 0, result.output);

      const requests = server.requestsTo('POST /add-translations');
      assert.equal(requests.length, 1);
      assert.equal(requests[0].headers.authorization, `Bearer ${API_KEY}`);
      assert.deepEqual(requests[0].form, {
        file: {filename: 'app.json', content: '{"key":"valeur"}'},
        document_path: 'app',
        document_format: 'json',
        language: 'fr',
        project_id: PROJECT_ID,
        merge_type: 'smart'
      });

      const paths = server.requests.map(toRoute);
      assert.deepEqual(paths, [
        'POST /graphql',
        'POST /sync',
        'POST /graphql',
        'POST /add-translations',
        'GET /export',
        'GET /export'
      ]);

      assert.match(result.stdout, /Adding translations → fr\n/);
      assert.match(result.stdout, /↑ fr\/app\.json app/);
    });

    it('uses the passive merge type by default', async () => {
      const {server, workspace, config} = await setup();
      workspace.writeConfig(config({files}));
      workspace.write('en/app.json', '{}');
      workspace.write('fr/app.json', '{}');

      const result = await workspace.run(['sync', '--add-translations']);

      assert.equal(result.code, 0, result.output);
      assert.equal(
        server.requestsTo('POST /add-translations')[0].form!.merge_type,
        'passive'
      );
    });

    it('rejects an invalid --merge-type', async () => {
      const {server, workspace, config} = await setup();
      workspace.writeConfig(config({files}));
      workspace.write('en/app.json', '{}');

      const result = await workspace.run([
        'sync',
        '--add-translations',
        '--merge-type=foo'
      ]);

      assert.notEqual(result.code, 0);
      assert.match(
        result.stderr,
        /Expected --merge-type=foo to be one of: smart, passive, force/
      );
      assert.equal(server.requestsTo('POST /sync').length, 0);
    });

    it('sends --version', async () => {
      const {server, workspace, config} = await setup();
      workspace.writeConfig(config({files}));
      workspace.write('en/app.json', '{}');
      workspace.write('fr/app.json', '{}');

      const result = await workspace.run([
        'sync',
        '--add-translations',
        '--version=v1'
      ]);

      assert.equal(result.code, 0, result.output);
      assert.equal(
        server.requestsTo('POST /add-translations')[0].form!.version,
        'v1'
      );
    });

    it('reports languages without local files', async () => {
      const {server, workspace, config} = await setup();
      workspace.writeConfig(config({files}));
      workspace.write('en/app.json', '{}');

      const result = await workspace.run(['sync', '--add-translations']);

      assert.equal(result.code, 0, result.output);
      assert.equal(server.requestsTo('POST /add-translations').length, 0);
      assert.match(result.stdout, /fr\/app\.json\n\s+No local file/);
    });

    it('is skipped when the project has only the main language', async () => {
      const project = buildProject({
        revisions: [buildRevision('en', {isMaster: true})]
      });
      const {server, workspace, config} = await setup({project});
      workspace.writeConfig(config({files}));
      workspace.write('en/app.json', '{}');
      workspace.write('fr/app.json', '{}');

      const result = await workspace.run(['sync', '--add-translations']);

      assert.equal(result.code, 0, result.output);
      assert.equal(server.requestsTo('POST /add-translations').length, 0);
      assert.doesNotMatch(result.stdout, /Adding translations/);
    });

    it('peeks the translations with --dry-run', async () => {
      const {server, workspace, config} = await setup({
        routes: {
          'POST /add-translations/peek': () => ({
            body: {
              data: {
                operations: {
                  'revision-fr': [
                    {
                      action: 'merge_on_proposed',
                      key: 'key',
                      text: 'valeur',
                      'previous-text': 'value'
                    }
                  ]
                },
                stats: {'revision-fr': {merge_on_proposed: 1}}
              }
            }
          })
        }
      });
      workspace.writeConfig(config({files}));
      workspace.write('en/app.json', '{}');
      workspace.write('fr/app.json', '{"key":"valeur"}');

      const result = await workspace.run([
        'sync',
        '--add-translations',
        '--dry-run',
        '--details'
      ]);

      assert.equal(result.code, 0, result.output);
      assert.equal(server.requestsTo('POST /add-translations').length, 0);
      assert.equal(server.requestsTo('POST /add-translations/peek').length, 1);
      assert.equal(server.requestsTo('GET /export').length, 0);
      assert.match(
        result.stdout,
        /• fr\/app\.json app\n\s+Merge on proposed \(1\)\n\s+key\n\s+- "value"\n\s+\+ "valeur"/
      );
      assert.match(result.stdout, /✓ Dry run completed in/);
    });

    it('fails with the server error message', async () => {
      const {server, workspace, config} = await setup({
        routes: {
          'POST /add-translations': () => ({status: 422, body: 'Bad merge'})
        }
      });
      workspace.writeConfig(config({files}));
      workspace.write('en/app.json', '{}');
      workspace.write('fr/app.json', '{}');

      const result = await workspace.run(['sync', '--add-translations']);

      assert.equal(result.code, 1);
      assert.match(result.stderr, /Bad merge/);
      assert.equal(server.requestsTo('GET /export').length, 0);
    });
  });

  describe('hooks', () => {
    it('runs every hook in order', async () => {
      const {workspace, config} = await setup();
      const hook = (name: string) => [`echo ${name} >> hooks.log`];
      workspace.writeConfig(
        config({
          files: [
            {
              ...files[0],
              hooks: {
                beforeSync: hook('beforeSync'),
                afterSync: hook('afterSync'),
                beforeAddTranslations: hook('beforeAddTranslations'),
                afterAddTranslations: hook('afterAddTranslations'),
                beforeExport: hook('beforeExport'),
                afterExport: hook('afterExport')
              }
            }
          ]
        })
      );
      workspace.write('en/app.json', '{}');
      workspace.write('fr/app.json', '{}');

      const result = await workspace.run(['sync', '--add-translations']);

      assert.equal(result.code, 0, result.output);
      assert.equal(
        workspace.read('hooks.log'),
        [
          'beforeSync',
          'afterSync',
          'beforeAddTranslations',
          'afterAddTranslations',
          'beforeExport',
          'afterExport',
          ''
        ].join('\n')
      );
      assert.match(
        result.stdout,
        /Hook: Before sync\n\s+\$ echo beforeSync >> hooks\.log/
      );
      assert.match(result.stdout, /Hook: After add translations/);
    });

    it('syncs files created by the beforeSync hook', async () => {
      const {server, workspace, config} = await setup();
      workspace.writeConfig(
        config({
          files: [
            {
              ...files[0],
              hooks: {
                beforeSync: ['mkdir -p en && echo {} > en/generated.json']
              }
            }
          ]
        })
      );

      const result = await workspace.run(['sync']);

      assert.equal(result.code, 0, result.output);
      assert.deepEqual(server.requestsTo('POST /sync').map(toDocumentPath), [
        'generated'
      ]);
    });

    it('stops when a hook fails', async () => {
      const {server, workspace, config} = await setup();
      workspace.writeConfig(
        config({files: [{...files[0], hooks: {beforeSync: ['exit 4']}}]})
      );
      workspace.write('en/app.json', '{}');

      const result = await workspace.run(['sync']);

      assert.equal(result.code, 4);
      assert.match(result.stdout, /✗ exit 4\n\s+Exit status: 4/);
      assert.equal(server.requestsTo('POST /sync').length, 0);
    });
  });
});
