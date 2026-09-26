import type {Meta} from '../state.ts';
import styles from '../ui/styles.ts';
import type LiveNode from './live-node.ts';

const NODE_UPDATE_STYLE_TIMEOUT = 600;

/*
  The Mutation component listens to DOM changes and is responsible of updating parent
  window nodes on mutation and messages FROM the Accent client.
*/
export default class Mutation {
  private readonly liveNode: LiveNode;

  constructor(liveNode: LiveNode) {
    this.liveNode = liveNode;
  }

  static nodeChange(node: HTMLElement, meta: Meta, text: string) {
    if (meta.attributeName) {
      this.attributeNodeChange(node, meta.attributeName, text);
    } else {
      this.textNodeChange(node, meta, text);
    }
  }

  static nodeStyleRefresh(
    node: Element,
    translation: {isConflicted?: boolean}
  ) {
    node.removeAttribute('class');
    styles.set(
      node,
      translation.isConflicted
        ? styles.translationNodeConflicted
        : styles.translationNode
    );
  }

  private static textNodeChange(node: HTMLElement, meta: Meta, text: string) {
    if (node.innerHTML === text) return;

    node.innerHTML = text.trim() === '' ? '–' : text;

    if (!meta.head) this.handleUpdatedNodeStyles(node);
  }

  private static attributeNodeChange(
    node: HTMLElement,
    attributeName: string,
    text: string
  ) {
    if (node.getAttribute(attributeName) === text) return;

    node.setAttribute(attributeName, text);
    this.handleUpdatedNodeStyles(node);
  }

  private static handleUpdatedNodeStyles(node: Element) {
    const originalStyles = node.getAttribute('style');

    styles.set(node, styles.translationNodeUpdated);
    setTimeout(
      () => styles.set(node, originalStyles),
      NODE_UPDATE_STYLE_TIMEOUT
    );
  }

  bindEvents() {
    new MutationObserver((records) => this.handleMutations(records)).observe(
      document,
      {
        attributes: true,
        characterData: true,
        childList: true,
        subtree: true
      }
    );
  }

  handleMutations(records: MutationRecord[]) {
    records.forEach((record) => {
      if (record.type === 'childList') {
        record.addedNodes.forEach((node) => {
          if (node.isConnected) this.liveNode.evaluate(node);
        });
      } else if (record.type === 'attributes') {
        const target = record.target as Element;
        this.liveNode.matchAttribute(
          target,
          target.getAttributeNode(record.attributeName)
        );
      } else if (record.type === 'characterData') {
        this.liveNode.matchText(record.target);
      }
    });
  }
}
