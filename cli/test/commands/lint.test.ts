import assert from 'node:assert/strict';
import {describe, it} from 'node:test';
import {API_KEY, PROJECT_ID, setup} from '../support/setup';

const files = [
  {format: 'json', source: 'en/*.json', target: '%slug%/%document_path%.json'}
];

const lintTranslation = (key: string, check: string, text: string) => ({
  key,
  text,
  messages: [{check, text, replacement: null}]
});

describe('lint', () => {
  it('reports no errors when the server finds none', async () => {
    const {server, workspace, config} = await setup();
    workspace.writeConfig(config({files}));
    workspace.write('en/app.json', '{"key":"value"}');
    workspace.write('fr/app.json', '{"key":"valeur"}');

    const result = await workspace.run(['lint']);

    assert.equal(result.code, 0, result.output);
    assert.match(result.stdout, /✓ No lint errors found in/);

    const requests = server.requestsTo('POST /lint');
    assert.equal(requests.length, 2);
    assert.equal(requests[0].headers.authorization, `Bearer ${API_KEY}`);
    assert.deepEqual(requests[0].form, {
      file: {filename: 'app.json', content: '{"key":"value"}'},
      document_path: 'app',
      document_format: 'json',
      language: 'en',
      project_id: PROJECT_ID
    });
    assert.equal(requests[1].form!.language, 'fr');
  });

  it('skips targets without a local file', async () => {
    const {server, workspace, config} = await setup();
    workspace.writeConfig(config({files}));
    workspace.write('en/app.json', '{}');

    const result = await workspace.run(['lint']);

    assert.equal(result.code, 0, result.output);
    assert.equal(server.requestsTo('POST /lint').length, 1);
  });

  it('displays errors grouped by file and exits with 1', async () => {
    const {workspace, config} = await setup({
      routes: {
        'POST /lint': ({form}) => ({
          body: {
            data: {
              lint_translations:
                form!.language === 'fr'
                  ? [
                      lintTranslation('greeting', 'trailing_space', 'Bonjour '),
                      lintTranslation(
                        'ellipsis',
                        'three_dots_ellipsis',
                        'Attendez...'
                      ),
                      lintTranslation('custom', 'unknown_check', 'Texte')
                    ]
                  : []
            }
          }
        })
      }
    });
    workspace.writeConfig(config({files}));
    workspace.write('en/app.json', '{}');
    workspace.write('fr/app.json', '{}');

    const result = await workspace.run(['lint']);

    assert.equal(result.code, 1, result.output);
    assert.match(result.stdout, /Lint errors \(3\)/);
    assert.match(
      result.stdout,
      /fr\/app\.json\n\s+greeting\n\s+✗ String contains a trailing space\n\s+"Bonjour "/
    );
    assert.match(
      result.stdout,
      /ellipsis\n\s+✗ String contains three dots \(\.\.\.\) instead of an ellipsis/
    );
    assert.match(result.stdout, /custom\n\s+✗ unknown_check/);
    assert.match(result.stdout, /✗ Found 3 lint errors in/);
    assert.doesNotMatch(result.stdout, /en\/app\.json/);
  });

  it('fails with the server error message', async () => {
    const {workspace, config} = await setup({
      routes: {'POST /lint': () => ({status: 500, body: 'Server exploded'})}
    });
    workspace.writeConfig(config({files}));
    workspace.write('en/app.json', '{}');

    const result = await workspace.run(['lint']);

    assert.equal(result.code, 1);
    assert.match(result.stderr, /Server exploded/);
  });
});
