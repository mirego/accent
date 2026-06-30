import Component from '@glimmer/component';
import {action} from '@ember/object';
import hljs from 'highlight.js';
import didInsert from '@ember/render-modifiers/modifiers/did-insert';
import {fn} from '@ember/helper';
import didUpdate from '@ember/render-modifiers/modifiers/did-update';

hljs.configure({
  languages: ['javascript', 'json', 'php', 'xml', 'yaml', 'properties']
});

interface Args {
  content: string;
  language: string | null;
}

export default class HighlightRender extends Component<Args> {
  <template>
    <div
      ...attributes
      class='render'
      {{didInsert (fn this.setupHighlight)}}
      {{didUpdate (fn this.setupHighlight) @content}}
    >
      <span
        data-highlight='content'
        class='render-source'
      >{{yield}}{{@content}}</span>
    </div>
  </template>
  @action
  setupHighlight(element: HTMLElement) {
    const content = element.querySelector(
      '[data-highlight="content"]'
    ) as HTMLElement;
    const existingPre = element.querySelector('pre');
    existingPre?.remove();

    const newPre = document.createElement('pre');
    newPre.append(content?.innerText || '');
    element.append(newPre);

    hljs.highlightElement(newPre);
  }
}
