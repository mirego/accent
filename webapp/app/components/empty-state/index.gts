import Component from '@glimmer/component';
import {scopedClass} from 'ember-scoped-css';

interface Args {
  icon?: unknown;
  title: string;
  text?: string;
}

export default class EmptyState extends Component<Args> {
  <template>
    <div ...attributes data-test-empty-state class='empty-state'>
      {{#if @icon}}
        <span class='empty-state-icon'>
          <@icon class={{scopedClass 'empty-state-iconSvg'}} />
        </span>
      {{/if}}

      <h3 class='empty-state-title'>{{@title}}</h3>

      {{#if @text}}
        <p class='empty-state-text'>{{@text}}</p>
      {{/if}}

      {{#if (has-block)}}
        <div class='empty-state-actions'>
          {{yield}}
        </div>
      {{/if}}
    </div>

    <style scoped>
      .empty-state {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 8px;
        width: 100%;
        max-width: 420px;
        margin: 0 auto;
        padding: 32px 24px;
        text-align: center;
      }

      .empty-state-icon {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        box-sizing: content-box;
        width: 24px;
        height: 24px;
        padding: 14px;
        margin-bottom: 4px;
        border-radius: 50%;
        color: var(--color-primary);
        background: color-mix(in srgb, var(--color-primary) 12%, transparent);
      }
      .empty-state-iconSvg {
        width: 24px;
        height: 24px;
        stroke: var(--color-primary);
      }

      .empty-state-title {
        margin: 0;
        font-size: 15px;
        font-weight: 700;
        color: var(--text-color-normal);
      }

      .empty-state-text {
        margin: 0;
        font-size: 13px;
        line-height: 1.5;
        color: color-mix(in srgb, var(--text-color-normal) 60%, transparent);
      }

      .empty-state-actions {
        margin-top: 6px;
        font-size: 13px;
      }
      .empty-state-actions :global(.link) {
        color: var(--color-primary);
        font-weight: 600;
        text-decoration: none;
      }
      .empty-state-actions :global(.link):focus,
      .empty-state-actions :global(.link):hover {
        text-decoration: underline;
      }
    </style>
  </template>
}
