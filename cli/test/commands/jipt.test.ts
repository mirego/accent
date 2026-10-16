import assert from 'node:assert/strict';
import {describe, it} from 'node:test';
import {buildProject} from '../support/factory';
import {API_KEY, PROJECT_ID, setup} from '../support/setup';

const files = [
  {format: 'json', source: 'en/*.json', target: '%slug%/%document_path%.json'}
];

const project = buildProject({
  documents: {
    entries: [
      {path: 'app', format: 'json'},
      {path: 'errors', format: 'json'}
    ],
    meta: {totalEntries: 2}
  }
});

describe('jipt', () => {
  it('writes the jipt files for every document of the project', async () => {
    const {server, workspace, config} = await setup({project});
    workspace.writeConfig(config({files}));
    workspace.write('en/app.json', {key: 'value'});

    const result = await workspace.run(['jipt', 'pseudo']);

    assert.equal(result.code, 0, result.output);
    assert.deepEqual(JSON.parse(workspace.read('pseudo/app.json')), {
      jipt: 'app'
    });
    assert.deepEqual(JSON.parse(workspace.read('pseudo/errors.json')), {
      jipt: 'errors'
    });
    assert.match(result.stdout, /↓ pseudo\/app\.json app → jipt/);
    assert.match(result.stdout, /✓ Export completed in/);

    const requests = server.requestsTo('GET /jipt-export');
    assert.equal(requests.length, 2);
    assert.equal(requests[0].headers.authorization, `Bearer ${API_KEY}`);
    assert.deepEqual(requests[0].query, {
      document_path: 'app',
      document_format: 'json',
      project_id: PROJECT_ID
    });
    assert.equal(server.requestsTo('GET /export').length, 0);
  });

  it('requires the pseudo language name', async () => {
    const {server, workspace, config} = await setup({project});
    workspace.writeConfig(config({files}));

    const result = await workspace.run(['jipt']);

    assert.notEqual(result.code, 0);
    assert.match(result.stderr, /Missing 1 required arg/);
    assert.match(result.stderr, /pseudoLanguageName/);
    assert.equal(server.requestsTo('GET /jipt-export').length, 0);
  });

  it('runs export hooks', async () => {
    const {workspace, config} = await setup({project});
    workspace.writeConfig(
      config({
        files: [
          {
            ...files[0],
            hooks: {
              beforeExport: ['echo before >> hooks.log'],
              afterExport: ['echo after >> hooks.log']
            }
          }
        ]
      })
    );

    const result = await workspace.run(['jipt', 'pseudo']);

    assert.equal(result.code, 0, result.output);
    assert.equal(workspace.read('hooks.log'), 'before\nafter\n');
  });

  it('fails with the server error message', async () => {
    const {workspace, config} = await setup({
      project,
      routes: {'GET /jipt-export': () => ({status: 404, body: 'Not found'})}
    });
    workspace.writeConfig(config({files}));

    const result = await workspace.run(['jipt', 'pseudo']);

    assert.equal(result.code, 1);
    assert.match(result.stderr, /Not found/);
    assert.ok(!workspace.exists('pseudo/app.json'));
  });
});
