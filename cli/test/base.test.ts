import assert from 'node:assert/strict';
import {describe, it} from 'node:test';
import {API_KEY, PROJECT_ID, setup} from './support/setup';

const files = [
  {format: 'json', source: 'en/*.json', target: '%slug%/%document_path%.json'}
];

describe('base command', () => {
  it('fetches the project with the api key and project id', async () => {
    const {server, workspace, config} = await setup({fullname: 'John Smith'});
    workspace.writeConfig(config({files}));

    const result = await workspace.run(['stats']);

    assert.equal(result.code, 0, result.output);
    assert.match(result.stderr, /My project as John Smith/);

    const [request] = server.requestsTo('POST /graphql');
    assert.equal(request.headers.authorization, `Bearer ${API_KEY}`);
    assert.equal(request.headers['content-type'], 'application/json');
    assert.deepEqual(request.json.variables, {project_id: PROJECT_ID});
    assert.match(request.json.query, /query ProjectDetails/);
  });

  it('omits the project id when not configured', async () => {
    const {server, workspace, config} = await setup();
    workspace.writeConfig(config({project: undefined, files}));

    const result = await workspace.run(['stats']);

    assert.equal(result.code, 0, result.output);
    assert.deepEqual(server.requestsTo('POST /graphql')[0].json.variables, {});
  });

  it('sends extra headers on every request', async () => {
    const {server, workspace, config} = await setup();
    workspace.writeConfig(
      config({files, extraHeaders: {'x-custom-header': 'custom'}})
    );
    workspace.write('en/app.json', {key: 'value'});

    const result = await workspace.run(['export']);

    assert.equal(result.code, 0, result.output);
    assert.ok(server.requests.length > 1);
    for (const request of server.requests) {
      assert.equal(request.headers['x-custom-header'], 'custom');
      assert.equal(request.headers.authorization, `Bearer ${API_KEY}`);
    }
  });

  it('overrides config values with environment variables', async () => {
    const {server, workspace} = await setup();
    workspace.writeConfig({
      apiUrl: 'http://127.0.0.1:1',
      apiKey: 'config-key',
      project: 'config-project',
      files
    });

    const result = await workspace.run(['stats'], {
      ACCENT_API_URL: server.url,
      ACCENT_API_KEY: 'env-key',
      ACCENT_PROJECT: 'env-project'
    });

    assert.equal(result.code, 0, result.output);
    const [request] = server.requestsTo('POST /graphql');
    assert.equal(request.headers.authorization, 'Bearer env-key');
    assert.deepEqual(request.json.variables, {project_id: 'env-project'});
  });

  it('fails when the api key is missing', async () => {
    const {server, workspace, config} = await setup();
    workspace.writeConfig(config({apiKey: undefined, files}));

    const result = await workspace.run(['stats']);

    assert.equal(result.code, 2);
    assert.match(result.stderr, /You must have an apiKey key in the config/);
    assert.equal(server.requests.length, 0);
  });

  it('fails when the api url is missing', async () => {
    const {server, workspace, config} = await setup();
    workspace.writeConfig(config({apiUrl: undefined, files}));

    const result = await workspace.run(['stats']);

    assert.equal(result.code, 2);
    assert.match(result.stderr, /You must have an apiUrl key in the config/);
    assert.equal(server.requests.length, 0);
  });

  it('fails when files are missing', async () => {
    const {server, workspace, config} = await setup();
    workspace.writeConfig(config());

    const result = await workspace.run(['stats']);

    assert.equal(result.code, 2);
    assert.match(result.stderr, /You must have at least 1 document set/);
    assert.equal(server.requests.length, 0);
  });

  it('fails when the config file does not exist', async () => {
    const {server, workspace} = await setup();

    const result = await workspace.run(['stats']);

    assert.notEqual(result.code, 0);
    assert.match(result.stderr, /accent\.json/);
    assert.equal(server.requests.length, 0);
  });

  it('fails when the server does not return the project', async () => {
    const {workspace, config} = await setup({project: () => null});
    workspace.writeConfig(config({files}));

    const result = await workspace.run(['stats']);

    assert.equal(result.code, 1);
    assert.match(result.stderr, /Can’t fetch the project on .* with key/);
  });

  it('fails when the server returns invalid JSON', async () => {
    const {workspace, config} = await setup({
      routes: {'POST /graphql': () => ({status: 500, body: 'oops'})}
    });
    workspace.writeConfig(config({files}));

    const result = await workspace.run(['stats']);

    assert.equal(result.code, 1);
    assert.match(result.stderr, /Can’t fetch the project/);
  });

  it('warns when many files share the same folder', async () => {
    const {workspace, config} = await setup();
    workspace.writeConfig(
      config({
        files: [
          {
            format: 'json',
            source: 'locales/en.json',
            target: 'locales/%slug%.json'
          },
          {
            format: 'json',
            source: 'locales/fr.json',
            target: 'locales/%slug%.json'
          }
        ]
      })
    );

    const result = await workspace.run(['stats']);

    assert.equal(result.code, 0, result.output);
    assert.match(result.stdout, /Warnings/);
    assert.match(result.stdout, /same folder path: locales\//);
  });

  describe('--config', () => {
    it('reads the config from a custom file', async () => {
      const {server, workspace, config} = await setup();
      workspace.writeConfig(config({files}), 'configs/custom.json');

      const long = await workspace.run([
        'stats',
        '--config',
        'configs/custom.json'
      ]);
      const short = await workspace.run(['stats', '-c', 'configs/custom.json']);
      const equal = await workspace.run([
        'stats',
        '--config=configs/custom.json'
      ]);

      assert.equal(long.code, 0, long.output);
      assert.equal(short.code, 0, short.output);
      assert.equal(equal.code, 0, equal.output);
      assert.match(long.stderr, /Fetching project configs\/custom\.json/);
      assert.equal(server.requestsTo('POST /graphql').length, 3);
    });

    it('fails when no value is given', async () => {
      const {server, workspace, config} = await setup();
      workspace.writeConfig(config({files}));

      const result = await workspace.run(['stats', '--config']);

      assert.notEqual(result.code, 0);
      assert.match(result.stderr, /Flag --config expects a value/);
      assert.equal(server.requests.length, 0);
    });
  });

  describe('--path', () => {
    it('runs the command from the given directory', async () => {
      const {server, workspace, config} = await setup();
      workspace.writeConfig(config({files}), 'app/accent.json');
      workspace.write('app/en/app.json', {key: 'value'});

      const result = await workspace.run(['sync', '--path', 'app']);

      assert.equal(result.code, 0, result.output);
      assert.equal(server.requestsTo('POST /sync').length, 1);
      assert.ok(workspace.exists('app/fr/app.json'));
      assert.ok(!workspace.exists('fr/app.json'));
    });

    it('fails when the directory does not exist', async () => {
      const {server, workspace} = await setup();

      const result = await workspace.run(['lint', '--path', 'missing']);

      assert.notEqual(result.code, 0);
      assert.match(
        result.stderr,
        /Flag --path must point to an existing directory: missing/
      );
      assert.equal(server.requests.length, 0);
    });

    it('fails when no value is given', async () => {
      const {server, workspace} = await setup();

      const result = await workspace.run(['lint', '--path']);

      assert.notEqual(result.code, 0);
      assert.match(result.stderr, /Flag --path expects a value/);
      assert.equal(server.requests.length, 0);
    });
  });
});
