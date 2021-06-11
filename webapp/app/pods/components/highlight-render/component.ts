import Component from '@glimmer/component';
import {action} from '@ember/object';
import hljs from 'highlight.js';

hljs.configure({
  languages: ['javascript', 'json', 'php', 'xml', 'yaml', 'properties'],
});

interface Args {
  content: string;
  language: string | null;
}

export default class HighlightRender extends Component<Args> {
  @action
  setupHighlight(element: HTMLElement) {
    const content = element.querySelector(
      '[data-highlight="content"]'
    ) as HTMLElement;
    let child = element.querySelector('pre');
    if (child) child.remove();

    child = document.createElement('pre');
    child.append(content?.innerText || '');
    element.append(child);

    hljs.highlightElement(child);
  }
}
