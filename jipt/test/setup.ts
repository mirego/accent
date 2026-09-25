import {Window} from 'happy-dom';

const window = new Window({url: 'http://localhost/'});

Object.assign(globalThis, {
  window,
  document: window.document,
  localStorage: window.localStorage,
  Node: window.Node,
  NodeFilter: window.NodeFilter,
  MutationObserver: window.MutationObserver,
  MessageEvent: window.MessageEvent
});

export const html = (markup: string) => {
  document.body.innerHTML = markup;
  return document.body;
};
