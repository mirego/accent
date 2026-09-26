import {html} from './setup.ts';
import assert from 'node:assert/strict';
import {beforeEach, test} from 'node:test';
import FrameListener from '../src/frame-listener.ts';
import LiveNode from '../src/mutation/live-node.ts';
import State from '../src/state.ts';
import type UI from '../src/ui/ui.ts';

let state: State;
let calls: string[];
let listener: FrameListener;

const send = (data: object) =>
  listener['handleAccentMessage']({data} as MessageEvent);

beforeEach(() => {
  localStorage.clear();
  state = new State();
  calls = [];
  const ui = {
    hideOverlay: () => calls.push('hideOverlay'),
    showLogin: () => calls.push('showLogin'),
    collapse: () => calls.push('collapse'),
    reloadFrame: () => calls.push('reloadFrame'),
    postMessage: (message: object) => calls.push(JSON.stringify(message))
  } as unknown as UI;
  listener = new FrameListener({
    ui,
    liveNode: new LiveNode(state),
    config: {i: 'p1', h: '', o: false},
    state
  });
});

test('ignores non jipt messages', () => {
  send({action: 'login'});
  listener['handleAccentMessage']({data: null} as MessageEvent);

  assert.deepEqual(calls, []);
});

test('listTranslations evaluates body and changeText updates it', () => {
  const root = html('<p>{^a@x}</p>');

  send({
    jipt: true,
    action: 'listTranslations',
    payload: {
      revisionId: 'r1',
      translations: {'a@x': {id: 't1', key: 'a@x', text: 'A'}}
    }
  });

  assert.deepEqual(calls, ['hideOverlay']);
  assert.equal(state.getCurrentRevision(), 'r1');
  assert.equal(root.textContent, 'A');

  send({
    jipt: true,
    action: 'changeText',
    payload: {translationId: 't1', text: 'B'}
  });
  assert.equal(root.textContent, 'B');

  send({
    jipt: true,
    action: 'updateTranslation',
    payload: {translationId: 't1', isConflicted: true}
  });
  assert.match(root.querySelector('span').getAttribute('style'), /#1ecc8c/);
});

test('routes simple actions', () => {
  state.setCurrentRevision('r1');

  send({jipt: true, action: 'login'});
  send({jipt: true, action: 'loggedIn'});
  send({jipt: true, action: 'redirectIfEmbedded'});
  send({jipt: true, action: 'revisionNotFound'});

  assert.deepEqual(calls, [
    'showLogin',
    'collapse',
    '{"projectId":"p1"}',
    'reloadFrame'
  ]);
  assert.equal(state.getCurrentRevision(), null);
});
