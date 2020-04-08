import State from '../state';
import randomClass from '../ui/random-class';
import styles from '../ui/styles';
import Mutation from './mutation';

const ACCENT_REGEX = /{\^(.+)}/;
const ACCENT_CLASS = randomClass();

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

  isLive(node: HTMLElement) {
    return !!this.state.nodes.get(node);
  }

  matchAttributes(node: HTMLElement) {
    Array.from(node.attributes).forEach((attribute) => {
      const translation = this.findTranslationByValue(attribute.value);
      if (!translation || !translation.text) return;

      styles.set(node, styles.translationNode);

      const newAttribute = this.replaceValue(attribute.value, translation.text);
      attribute.value = newAttribute;

      this.state.addReference(node, translation, {
        attributeName: attribute.name,
      });
    });
  }

  matchNode(node: Element) {
    const translation = this.findTranslationByValue(node.nodeValue);

    if (!translation || !translation.text) return;
  }

  matchText(node: Element) {
    const translation = this.findTranslationByValue(node.nodeValue);

    if (!translation || translation.text === undefined) return;
    if (translation.text === '') translation.text = '–';

    const parentNode = node.parentNode as Element;

    const span = document.createElement('span');
    span.innerHTML = translation.text;
    span.setAttribute('class', ACCENT_CLASS);

    const newContent = this.replaceValue(node.nodeValue, span.outerHTML);
    if (newContent === node.nodeValue) return;

    parentNode.innerHTML = this.replaceValue(parentNode.innerHTML, newContent);
    const newNode = parentNode.getElementsByClassName(
      ACCENT_CLASS
    )[0] as HTMLElement;
    Mutation.nodeStyleRefresh(newNode, translation);

    this.state.addReference(newNode, translation);
  }

  evaluate(node: HTMLElement) {
    node.childNodes &&
      node.childNodes.forEach((node: HTMLElement) => {
        this.evaluate(node);
        if (node.attributes) this.matchAttributes(node);
      });

    if (node.nodeType === Node.TEXT_NODE) {
      this.matchText(node);
    }
  }

  private replaceValue(value: string, newContent: string) {
    return value.replace(ACCENT_REGEX, newContent);
  }

  private valueMatch(value: string) {
    return value.match(ACCENT_REGEX);
  }

  private findTranslationByValue(value: string) {
    if (!value) return;

    const match = this.valueMatch(value);
    if (!match) return;

    const id = match[1];

    return this.state.translationById(id);
  }
}
