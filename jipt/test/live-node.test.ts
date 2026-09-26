import {html} from './setup.ts';
import assert from 'node:assert/strict';
import {beforeEach, describe, test} from 'node:test';
import LiveNode from '../src/mutation/live-node.ts';
import Mutation from '../src/mutation/mutation.ts';
import State from '../src/state.ts';

const translations = {
  'title@app': {id: 't1', key: 'title@app', text: 'Hello'},
  'body@app': {id: 't2', key: 'body@app', text: '<b>World</b>'},
  'empty@app': {id: 't3', key: 'empty@app', text: ''},
  'conflict@app': {id: 't4', key: 'conflict@app', text: 'C', isConflicted: true}
};

let state: State;
let liveNode: LiveNode;

beforeEach(() => {
  state = new State();
  state.projectTranslations = structuredClone(translations);
  liveNode = new LiveNode(state);
});

describe('evaluate', () => {
  test('replaces text marker with span and keeps siblings', () => {
    const root = html('<p id="p">Before {^title@app} after<i>x</i></p>');
    const input = root.querySelector('i');

    liveNode.evaluate(root);

    const p = root.querySelector('#p');
    assert.equal(p.textContent, 'Before Hello afterx');
    assert.equal(p.querySelector('i'), input);
    const span = p.querySelector('span');
    assert.equal(span.innerHTML, 'Hello');
    assert.ok(liveNode.isLive(span));
    assert.deepEqual([...state.nodes.get(span)], ['title@app']);
    assert.ok(state.refs.get('t1').has(span));
  });

  test('replaces many markers in one text node', () => {
    const root = html('<p>{^title@app} - {^body@app}</p>');

    liveNode.evaluate(root);

    const spans = root.querySelectorAll('span');
    assert.equal(spans.length, 2);
    assert.equal(spans[1].innerHTML, '<b>World</b>');
    assert.equal(root.querySelector('p').textContent, 'Hello - World');
  });

  test('uses dash for empty text', () => {
    const root = html('<p>{^empty@app}</p>');

    liveNode.evaluate(root);

    assert.equal(root.querySelector('span').textContent, '–');
    assert.equal(state.projectTranslations['empty@app'].text, '');
  });

  test('applies conflicted style', () => {
    const root = html('<p>{^conflict@app}</p>');

    liveNode.evaluate(root);

    assert.match(root.querySelector('span').getAttribute('style'), /#1ecc8c/);
  });

  test('ignores unknown keys and prototype keys', () => {
    const markup = '<p>{^unknown@app} {^constructor} {^__proto__}</p>';
    const root = html(markup);

    liveNode.evaluate(root);

    assert.equal(root.innerHTML, markup);
  });

  test('replaces attribute markers', () => {
    const root = html(
      '<input placeholder="{^title@app}" title="x {^body@app}">'
    );

    liveNode.evaluate(root);

    const input = root.querySelector('input');
    assert.equal(input.getAttribute('placeholder'), 'Hello');
    assert.equal(input.getAttribute('title'), 'x <b>World</b>');
    assert.equal(state.refs.get('t1').get(input).attributeName, 'placeholder');
    assert.deepEqual([...state.nodes.get(input)].sort(), [
      'body@app',
      'title@app'
    ]);
  });

  test('does not interpret $ patterns in translation', () => {
    state.projectTranslations['title@app'].text = "$& $' $1";
    const root = html('<input value="{^title@app}">');

    liveNode.evaluate(root);

    assert.equal(root.querySelector('input').getAttribute('value'), "$& $' $1");
  });

  test('handles nested nodes', () => {
    const root = html(
      '<div><ul><li>{^title@app}</li><li><a title="{^body@app}">{^empty@app}</a></li></ul></div>'
    );

    liveNode.evaluate(root);

    assert.equal(root.querySelectorAll('span').length, 2);
    assert.equal(root.querySelector('a').getAttribute('title'), '<b>World</b>');
  });
});

describe('Mutation', () => {
  test('nodeChange updates text node', () => {
    const root = html('<p>{^title@app}</p>');
    liveNode.evaluate(root);
    const span = root.querySelector('span');

    Mutation.nodeChange(span, {head: true}, 'New');

    assert.equal(span.innerHTML, 'New');
  });

  test('nodeChange updates attribute and not inner html', () => {
    const root = html('<a title="{^title@app}">keep</a>');
    liveNode.evaluate(root);
    const a = root.querySelector('a');

    Mutation.nodeChange(a, state.refs.get('t1').get(a), 'New');

    assert.equal(a.getAttribute('title'), 'New');
    assert.equal(a.innerHTML, 'keep');
  });

  test('handleMutations evaluates added nodes and attributes', () => {
    const root = html('<div id="d"></div>');
    const div = root.querySelector('#d');
    const mutation = new Mutation(liveNode);

    const p = document.createElement('p');
    p.textContent = '{^title@app}';
    div.append(p);
    div.setAttribute('title', '{^body@app}');

    mutation.handleMutations([
      {type: 'childList', addedNodes: [p], target: div},
      {type: 'attributes', attributeName: 'title', target: div}
    ] as unknown as MutationRecord[]);

    assert.equal(p.querySelector('span').textContent, 'Hello');
    assert.equal(div.getAttribute('title'), '<b>World</b>');
  });
});
