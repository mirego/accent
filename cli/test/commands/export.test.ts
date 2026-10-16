import assert from 'node:assert/strict';
import {describe, it} from 'node:test';
import {buildProject, buildRevision} from '../support/factory';
import {API_KEY, PROJECT_ID, setup} from '../support/setup';

const files = [
  {format: 'json', source: 'en/*.json', target: '%slug%/%document_path%.json'}
];

describe('export', () => {
  it('writes every language of every document to the local files', async () => {
    const {server, workspace, config} = await setup();
    workspace.writeConfig(config({files}));
    workspace.write('en/app.json', {key: 'value'});
    workspace.write('en/errors.json', {key: 'value'});

    const result = await workspace.run(['export']);

    assert.equal(result.code, 0, result.output);
    assert.deepEqual(JSON.parse(workspace.read('en/app.json')), {
      exported: 'en:app'
    });
    assert.deepEqual(JSON.parse(workspace.read('fr/app.json')), {
      exported: 'fr:app'
    });
    assert.deepEqual(JSON.parse(workspace.read('en/errors.json')), {
      exported: 'en:errors'
    });
    assert.deepEqual(JSON.parse(workspace.read('fr/errors.json')), {
      exported: 'fr:errors'
    });

    assert.match(result.stdout, /Writing files locally/);
    assert.match(result.stdout, /↓ fr\/app\.json app → fr/);
    assert.match(result.stdout, /✓ Export completed in/);

    const requests = server.requestsTo('GET /export');
    assert.equal(requests.length, 4);
    assert.equal(requests[0].headers.authorization, `Bearer ${API_KEY}`);
    assert.deepEqual(
      requests
        .map(({query}) => query)
        .find(
          ({language, document_path}) =>
            language === 'fr' && document_path === 'app'
        ),
      {
        document_path: 'app',
        document_format: 'json',
        order_by: 'index',
        language: 'fr',
        project_id: PROJECT_ID
      }
    );
  });

  it('sends --order-by and --version', async () => {
    const {server, workspace, config} = await setup();
    workspace.writeConfig(config({files}));
    workspace.write('en/app.json', {key: 'value'});

    const result = await workspace.run([
      'export',
      '--order-by=key',
      '--version=v1.2'
    ]);

    assert.equal(result.code, 0, result.output);
    for (const {query} of server.requestsTo('GET /export')) {
      assert.equal(query.order_by, 'key');
      assert.equal(query.version, 'v1.2');
    }
  });

  it('rejects an invalid --order-by', async () => {
    const {server, workspace, config} = await setup();
    workspace.writeConfig(config({files}));
    workspace.write('en/app.json', {key: 'value'});

    const result = await workspace.run(['export', '--order-by=foo']);

    assert.notEqual(result.code, 0);
    assert.match(
      result.stderr,
      /Expected --order-by=foo to be one of: index, key/
    );
    assert.equal(server.requestsTo('GET /export').length, 0);
  });

  it('uses the revision slug over the language slug', async () => {
    const project = buildProject({
      revisions: [
        buildRevision('en', {isMaster: true}),
        buildRevision('fr', {slug: 'fr-CA'})
      ]
    });
    const {server, workspace, config} = await setup({project});
    workspace.writeConfig(config({files}));
    workspace.write('en/app.json', {key: 'value'});

    const result = await workspace.run(['export']);

    assert.equal(result.code, 0, result.output);
    assert.ok(workspace.exists('fr-CA/app.json'));
    assert.deepEqual(
      server
        .requestsTo('GET /export')
        .map(({query}) => query.language)
        .sort(),
      ['en', 'fr-CA']
    );
  });

  it('uses the file name with slug suffix name pattern', async () => {
    const {server, workspace, config} = await setup();
    workspace.writeConfig(
      config({
        files: [
          {
            format: 'strings',
            source: 'Resources/Localizable.en.strings',
            target: 'Resources/Localizable.%slug%.strings'
          }
        ]
      })
    );
    workspace.write('Resources/Localizable.en.strings', '"a" = "b";');

    const result = await workspace.run(['export']);

    assert.equal(result.code, 0, result.output);
    assert.ok(workspace.exists('Resources/Localizable.fr.strings'));
    const requests = server.requestsTo('GET /export');
    assert.deepEqual(
      requests.map(({query}) => query.document_path),
      ['Localizable', 'Localizable']
    );
    assert.equal(requests[0].query.document_format, 'strings');
  });

  it('uses the parent directory name pattern', async () => {
    const {server, workspace, config} = await setup();
    workspace.writeConfig(
      config({
        files: [
          {
            format: 'gettext',
            source: 'priv/gettext/en/LC_MESSAGES/*.po',
            target: 'priv/gettext/%slug%/LC_MESSAGES/%original_file_name%.po'
          }
        ]
      })
    );
    workspace.write('priv/gettext/en/LC_MESSAGES/default.po', '');

    const result = await workspace.run(['export']);

    assert.equal(result.code, 0, result.output);
    assert.ok(workspace.exists('priv/gettext/fr/LC_MESSAGES/default.po'));
    assert.deepEqual(
      server.requestsTo('GET /export').map(({query}) => query.document_path),
      ['default', 'default']
    );
  });

  it('uses the file with parent directory name pattern', async () => {
    const {server, workspace, config} = await setup();
    workspace.writeConfig(
      config({
        files: [
          {
            format: 'json',
            source: 'translations/en/**/*.json',
            target: 'translations/%slug%/%document_path%.json',
            namePattern: 'fileWithParentDirectory'
          }
        ]
      })
    );
    workspace.write('translations/en/admin/users/list.json', {});

    const result = await workspace.run(['export']);

    assert.equal(result.code, 0, result.output);
    assert.ok(workspace.exists('translations/fr/admin/users/list.json'));
    assert.deepEqual(
      server.requestsTo('GET /export').map(({query}) => query.document_path),
      ['admin/users/list', 'admin/users/list']
    );
  });

  it('runs export hooks in order', async () => {
    const {workspace, config} = await setup();
    workspace.writeConfig(
      config({
        files: [
          {
            ...files[0],
            hooks: {
              beforeExport: ['echo before >> hooks.log'],
              afterExport: ['echo after >> hooks.log', 'echo done']
            }
          }
        ]
      })
    );
    workspace.write('en/app.json', {key: 'value'});

    const result = await workspace.run(['export']);

    assert.equal(result.code, 0, result.output);
    assert.equal(workspace.read('hooks.log'), 'before\nafter\n');
    assert.match(result.stdout, /Hook: Before export/);
    assert.match(result.stdout, /Hook: After export/);
    assert.match(result.stdout, /✓ echo done\n\s+done/);
  });

  it('picks up files created by the beforeExport hook', async () => {
    const {server, workspace, config} = await setup();
    workspace.writeConfig(
      config({
        files: [
          {
            ...files[0],
            hooks: {
              beforeExport: ['mkdir -p en && echo {} > en/generated.json']
            }
          }
        ]
      })
    );

    const result = await workspace.run(['export']);

    assert.equal(result.code, 0, result.output);
    assert.ok(workspace.exists('fr/generated.json'));
    assert.equal(server.requestsTo('GET /export').length, 2);
  });

  it('stops when a hook fails', async () => {
    const {server, workspace, config} = await setup();
    workspace.writeConfig(
      config({
        files: [
          {...files[0], hooks: {beforeExport: ['echo broken >&2; exit 3']}}
        ]
      })
    );
    workspace.write('en/app.json', {key: 'value'});

    const result = await workspace.run(['export']);

    assert.equal(result.code, 3);
    assert.match(result.stdout, /✗ echo broken >&2; exit 3\n\s+broken/);
    assert.equal(server.requestsTo('GET /export').length, 0);
  });

  it('fails with the server error message', async () => {
    const {workspace, config} = await setup({
      routes: {'GET /export': () => ({status: 422, body: 'Unknown document'})}
    });
    workspace.writeConfig(config({files}));
    workspace.write('en/app.json', {key: 'value'});

    const result = await workspace.run(['export']);

    assert.equal(result.code, 1);
    assert.match(result.stderr, /Unknown document/);
    assert.deepEqual(JSON.parse(workspace.read('en/app.json')), {key: 'value'});
  });
});
