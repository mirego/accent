import type State from '../state.ts';
import styles from '../ui/styles.ts';
import Mutation from './mutation.ts';

const MARKER = '{^';
const ACCENT_REGEX = /{\^([^}]+)}/;
const ACCENT_REGEX_GLOBAL = /{\^([^}]+)}/g;

/*
  The LiveNode component takes care of NodeElement modified by Accent client.

  It replace the original parent window node values with Accent translations and
  it modifies the state to keep track of added nodes and translations.
*/
export default class LiveNode {
  private readonly state: State;

  constructor(state: State) {
    this.state = state;
  }

  isLive(node: Node) {
    return this.state.nodes.has(node as HTMLElement);
  }

  matchAttributes(node: Element) {
    Array.from(node.attributes).forEach((attribute) =>
      this.matchAttribute(node, attribute)
    );
  }

  matchAttribute(node: Element, attribute: Attr | null) {
    const value = attribute?.value;
    if (!value || !value.includes(MARKER)) return;

    const match = value.match(ACCENT_REGEX);
    const translation = match && this.state.translationById(match[1]);
    if (!translation || !translation.text) return;

    attribute.value = value.replace(ACCENT_REGEX, () => translation.text);
    styles.set(node, styles.translationNode);

    this.state.addReference(node as HTMLElement, translation, {
      attributeName: attribute.name
    });
  }

  matchText(node: Node) {
    const value = node.nodeValue;
    if (!value || !value.includes(MARKER) || !node.parentNode) return;

    const parts: (Node | string)[] = [];
    let last = 0;

    for (const match of value.matchAll(ACCENT_REGEX_GLOBAL)) {
      const translation = this.state.translationById(match[1]);
      if (!translation || translation.text === undefined) continue;

      const span = document.createElement('span');
      span.innerHTML = translation.text === '' ? '–' : translation.text;
      Mutation.nodeStyleRefresh(span, translation);
      this.state.addReference(span, translation);

      if (match.index > last) parts.push(value.slice(last, match.index));
      parts.push(span);
      last = match.index + match[0].length;
    }

    if (!parts.length) return;
    if (last < value.length) parts.push(value.slice(last));

    (node as ChildNode).replaceWith(...parts);
  }

  evaluate(root: Node) {
    const texts: Node[] = [];
    const walker = document.createTreeWalker(
      root,
      NodeFilter.SHOW_ELEMENT | NodeFilter.SHOW_TEXT
    );

    for (let node = walker.currentNode; node; node = walker.nextNode()) {
      if (node.nodeType === Node.TEXT_NODE) {
        if (node.nodeValue.includes(MARKER)) texts.push(node);
      } else if (node.nodeType === Node.ELEMENT_NODE) {
        this.matchAttributes(node as Element);
      }
    }

    texts.forEach((node) => this.matchText(node));
  }
}
