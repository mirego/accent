import assert from 'node:assert/strict';
import {describe, it} from 'node:test';
import {API_KEY, PROJECT_ID, setup} from '../support/setup';

const files = [
  {format: 'json', source: 'en/*.json', target: '%slug%/%document_path%.json'}
];

describe('format', () => {
  it('formats existing local files with the server response', async () => {
    const {server, workspace, config} = await setup({
      routes: {
        'POST /format': ({form}) => ({
          body:
            form!.language === 'en'
              ? '{"formatted": true}\n'
              : (form!.file as {content: string}).content
        })
      }
    });
    workspace.writeConfig(config({files}));
    workspace.write('en/app.json', '{"key":"value"}');
    workspace.write('fr/app.json', '{"key":"valeur"}');

    const result = await workspace.run(['format']);

    assert.equal(result.code, 0, result.output);
    assert.equal(workspace.read('en/app.json'), '{"formatted": true}\n');
    assert.equal(workspace.read('fr/app.json'), '{"key":"valeur"}');

    assert.match(result.stdout, /Formatting files \(2\)/);
    assert.match(result.stdout, /✎ en\/app\.json/);
    assert.match(result.stdout, /• fr\/app\.json/);
    assert.match(result.stdout, /✓ Formatted 2 files, 1 changed in/);

    const requests = server.requestsTo('POST /format');
    assert.equal(requests.length, 2);
    assert.equal(requests[0].headers.authorization, `Bearer ${API_KEY}`);
    assert.deepEqual(requests[0].form, {
      file: {filename: 'app.json', content: '{"key":"value"}'},
      document_path: 'app',
      document_format: 'json',
      language: 'en',
      project_id: PROJECT_ID,
      order_by: 'index'
    });
  });

  it('skips targets without a local file', async () => {
    const {server, workspace, config} = await setup();
    workspace.writeConfig(config({files}));
    workspace.write('en/app.json', '{}');

    const result = await workspace.run(['format']);

    assert.equal(result.code, 0, result.output);
    assert.equal(server.requestsTo('POST /format').length, 1);
    assert.ok(!workspace.exists('fr/app.json'));
    assert.match(result.stdout, /Formatted 1 file, 1 changed/);
  });

  it('sends --order-by', async () => {
    const {server, workspace, config} = await setup();
    workspace.writeConfig(config({files}));
    workspace.write('en/app.json', '{}');

    const result = await workspace.run(['format', '--order-by=-key']);

    assert.equal(result.code, 0, result.output);
    assert.equal(server.requestsTo('POST /format')[0].form!.order_by, '-key');
  });

  it('rejects an invalid --order-by', async () => {
    const {server, workspace, config} = await setup();
    workspace.writeConfig(config({files}));
    workspace.write('en/app.json', '{}');

    const result = await workspace.run(['format', '--order-by=foo']);

    assert.notEqual(result.code, 0);
    assert.match(
      result.stderr,
      /Expected --order-by=foo to be one of: index, key, -index, -key/
    );
    assert.equal(server.requestsTo('POST /format').length, 0);
  });

  it('fails with the server error message and keeps the file', async () => {
    const {workspace, config} = await setup({
      routes: {'POST /format': () => ({status: 422, body: 'Invalid file'})}
    });
    workspace.writeConfig(config({files}));
    workspace.write('en/app.json', '{"key":"value"}');

    const result = await workspace.run(['format']);

    assert.equal(result.code, 1);
    assert.match(result.stderr, /Invalid file/);
    assert.equal(workspace.read('en/app.json'), '{"key":"value"}');
  });
});
