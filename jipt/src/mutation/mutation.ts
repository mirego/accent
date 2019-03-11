import styles from '../ui/styles';
import LiveNode from './live-node';

const NODE_UPDATE_STYLE_TIMEOUT = 600;

/*
  The Mutation component listens to DOM changes and is responsible of updating parent
  window nodes on mutation and messages FROM the Accent client.
*/
export default class Mutation {
  static nodeChange(node: Element, meta: any, text: string) {
    this.textNodeChange(node, meta, text);
    this.attributeNodeChange(node, meta, text);
  }

  private static textNodeChange(node: Element, meta: any, text: string) {
    if (node.innerHTML === text) return;

    node.innerHTML = text;
    if (!meta.head) this.handleUpdatedNodeStyles(node);
  }

  private static attributeNodeChange(node, meta, text) {
    if (!meta.attributeName) return;
    if (node.getAttribute(meta.attributeName) === text) return;

    node.setAttribute(meta.attributeName, text);
    this.handleUpdatedNodeStyles(node);
  }

  private static handleUpdatedNodeStyles(node: Element) {
    styles.set(node, styles.translationNodeUpdated);
    setTimeout(() => {
      styles.set(node, styles.translationNode);
    }, NODE_UPDATE_STYLE_TIMEOUT);
  }

  private readonly liveNode: LiveNode;

  constructor(liveNode: LiveNode) {
    this.liveNode = liveNode;
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
      subtree: true
    });
  }

  handleNodeMutation(node) {
    if (node.nodeType === Node.TEXT_NODE) this.liveNode.matchText(node.target);
    if (node.type === 'childList') {
      node.addedNodes.forEach((node: Element) => this.liveNode.evaluate(node));
    }
    if (node.type === 'attributes') this.liveNode.matchAttributes(node.target);
    if (node.type === 'characterData') this.liveNode.matchText(node.target);
  }
}
