import Component from '@glimmer/component';
import {action} from '@ember/object';
import {on} from '@ember/modifier';
import {fn} from '@ember/helper';
import LoadingSvg from 'accent-webapp/svgs/assets/loading.svg';
import {scopedClass} from 'ember-scoped-css';

interface Args {
  onClick: () => void;
  loading?: boolean;
  disabled?: boolean;
}

export default class AsyncButton extends Component<Args> {
  <template>
    <button
      class='button local-button {{if @loading "button--loading"}}'
      disabled={{this.disabled}}
      ...attributes
      {{on 'click' (fn this.onClick)}}
    >
      <div class='content'>
        <span class='label local-label'>{{yield}}</span>

        <LoadingSvg class={{scopedClass 'loading'}} />
      </div>
    </button>

    <style scoped>
      .local-button {
        padding: 0 !important;
      }
      .local-button:global(.button--loading) {
        cursor: default;
      }
      .local-button:global(.button--loading) .local-label {
        transform: translate3d(-100%, 0, 0);
      }
      .local-button:global(.button--loading) .loading {
        top: calc(50% - 7px);
        left: calc(50% - 9px);
      }
      .local-button:global(.button--filled) .loading {
        fill: #fff;
      }
      .local-button:global(.button--filled.button--white) .loading {
        fill: currentColor;
      }
      .local-button:global(.button--iconOnly) .local-label {
        padding-left: 7px;
        padding-right: 7px;
      }
      .local-button:global(.button--small.button--loading) .loading {
        width: 14px;
        top: 0;
        left: calc(50% - 5px);
      }

      .content {
        display: flex;
        align-items: center;
        position: relative;
        overflow: hidden;
        line-height: 1.3;
      }

      .local-label {
        transition: 0.2s ease-in-out;
        transition-property: transform;
        transform: translate3d(0, 0, 0);
        display: flex;
        gap: 4px;
        align-items: center;
        padding: 5px 12px;
      }

      .loading {
        transition: 0.2s ease-in-out;
        transition-property: left;
        will-change: left;
        width: 15px;
        position: absolute;
        top: calc(50% - 8px);
        left: 100%;
        fill: var(--color-black);
      }
    </style>
  </template>
  get disabled() {
    return this.args.disabled || this.args.loading;
  }

  @action
  onClick(event: Event) {
    event.preventDefault();
    if (this.args.disabled) return;

    if (typeof this.args.onClick === 'function') this.args.onClick();
  }
}
