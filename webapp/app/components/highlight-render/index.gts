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

    <style scoped>
      .render {
        height: var(--highlight-render-height, calc(100dvh - 300px));
        overflow: auto;
        overscroll-behavior: contain;
      }

      .render :global(pre) {
        padding: 10px;
        border-top: 0;
        box-shadow: inset 0 2px 6px rgba(0, 0, 0, 0.05);
        background: none;
        font-family: var(--font-monospace);
        font-size: 11px;
        line-height: 1.7;
      }

      .render-source {
        display: none;
      }
    </style>
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
