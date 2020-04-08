import styles from '../ui/styles';
import LiveNode from './live-node';

const NODE_UPDATE_STYLE_TIMEOUT = 600;

interface Translation {
  isConflicted: boolean;
}

/*
  The Mutation component listens to DOM changes and is responsible of updating parent
  window nodes on mutation and messages FROM the Accent client.
*/
export default class Mutation {
  private readonly liveNode: LiveNode;

  constructor(liveNode: LiveNode) {
    this.liveNode = liveNode;
  }

  static nodeChange(node: HTMLElement, meta: any, text: string) {
    this.textNodeChange(node, meta, text);
    this.attributeNodeChange(node, meta, text);
  }

  static nodeStyleRefresh(node: HTMLElement, translation: Translation) {
    node.removeAttribute('class');

    if (translation.isConflicted) {
      styles.set(node, styles.translationNodeConflicted);
    } else {
      styles.set(node, styles.translationNode);
    }
  }

  private static textNodeChange(node: HTMLElement, meta: any, text: string) {
    if (node.innerHTML === text) return;
    let updatedText = text;

    if (text.trim() === '') updatedText = '–';

    node.innerHTML = updatedText;

    if (!meta.head) this.handleUpdatedNodeStyles(node);
  }

  private static attributeNodeChange(
    node: HTMLElement,
    meta: any,
    text: string
  ) {
    if (!meta.attributeName) return;
    if (node.getAttribute(meta.attributeName) === text) return;

    node.setAttribute(meta.attributeName, text);
    this.handleUpdatedNodeStyles(node);
  }

  private static handleUpdatedNodeStyles(node: Element) {
    const originalStyles = node.getAttribute('style');

    styles.set(node, styles.translationNodeUpdated);
    setTimeout(() => {
      styles.set(node, originalStyles);
    }, NODE_UPDATE_STYLE_TIMEOUT);
  }

  bindEvents() {
    const onMutation = (instance: MutationRecord[]) => {
      return instance.forEach(this.handleNodeMutation.bind(this));
    };

    new MutationObserver(onMutation).observe(document, {
      attributes: true,
      characterData: true,
      characterDataOldValue: true,
      childList: true,
      subtree: true,
    });
  }

  handleNodeMutation(node) {
    if (node.nodeType === Node.TEXT_NODE) this.liveNode.matchText(node.target);
    if (node.type === 'childList') {
      node.addedNodes.forEach((node: HTMLElement) =>
        this.liveNode.evaluate(node)
      );
    }
    if (node.type === 'attributes') this.liveNode.matchAttributes(node.target);
    if (node.type === 'characterData') this.liveNode.matchText(node.target);
  }
}
