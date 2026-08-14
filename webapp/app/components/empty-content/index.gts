import Component from '@glimmer/component';
import {scopedClass} from 'ember-scoped-css';

interface Args {
  success?: boolean;
  center?: boolean;
  background?: string;
  text: string;
  icon?: unknown;
}

export default class EmptyContent extends Component<Args> {
  <template>
    <div
      ...attributes
      data-test-empty-content
      class='empty-content
        {{if @center "empty-content--center"}}
        {{if this.isBackgroundPrimary "empty-content--primary"}}'
    >
      {{#if (has-block)}}
        {{yield}}
      {{else}}
        {{#if @icon}}
          <@icon class={{scopedClass 'icon'}} />
        {{/if}}
        {{@text}}
      {{/if}}
    </div>

    <style scoped>
      .empty-content {
        padding: 15px 16px 16px;
        width: 100%;
        max-width: 520px;
        font-size: 13px;
        font-weight: 300;
        border-radius: var(--border-radius);
        line-height: 1.5;
        color: var(--color-grey);
        background-color: var(--body-background);
      }
      .empty-content.empty-content--primary {
        color: hsl(from var(--color-primary) h s 50%);
        background-color: color-mix(
          in srgb,
          var(--color-primary) 50%,
          transparent
        );
      }
      .empty-content.empty-content--primary :global(svg) {
        color: var(--color-primary);
      }
      .empty-content.empty-content--center {
        display: flex;
        align-items: center;
        justify-content: center;
        flex-direction: column;
        margin-left: auto;
        margin-right: auto;
        text-align: center;
        padding: 30px 15px;
        border-left: 0;
      }
      .empty-content :global(svg) {
        color: currentColor;
        opacity: 0.5;
      }
      .empty-content :global(.link) {
        color: var(--color-primary);
        text-decoration: none;
      }
      .empty-content :global(.link):focus,
      .empty-content :global(.link):hover {
        text-decoration: underline;
      }
      .empty-content :global(.icon),
      .empty-content .icon {
        display: block;
        opacity: 0.8;
        width: 60px;
        height: 60px;
        margin-bottom: 10px;
      }
    </style>
  </template>
  get isBackgroundPrimary() {
    return this.args.background === 'primary';
  }
}
