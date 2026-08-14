import Component from '@glimmer/component';
import {action} from '@ember/object';
import {readOnly} from '@ember/object/computed';
import {on} from '@ember/modifier';
import {fn} from '@ember/helper';
import ActivitySvg from 'accent-webapp/svgs/assets/activity.svg';
import CheckSvg from 'accent-webapp/svgs/assets/check.svg';
import XSvg from 'accent-webapp/svgs/assets/x.svg';
import {scopedClass} from 'ember-scoped-css';

interface Args {
  flash: {
    exiting: boolean;
    type: string;
    destroyMessage: () => void;
  };
}

export default class FlashMessage extends Component<Args> {
  <template>
    <div
      class='flash {{if this.isExiting "is-exiting"}}'
      data-type={{this.type}}
    >
      <button class='deleteButton' {{on 'click' (fn this.close)}}>
        <XSvg class={{scopedClass 'deleteButton-icon'}} />
      </button>

      <div class='content'>
        {{#if this.hasIcon}}
          <div class='icon'>
            {{#if this.isSuccess}}
              <CheckSvg />
            {{else if this.isError}}
              <XSvg />
            {{else if this.isSocket}}
              <ActivitySvg />
            {{/if}}
          </div>
        {{/if}}
        <p class='text'>
          {{@flash.message}}
        </p>
      </div>
    </div>

    <style scoped>
      .flash {
        position: relative;
        margin-bottom: 10px;
        width: 400px;
        background: #fff;
        border-radius: var(--border-radius);
        box-shadow: 0 1px 12px var(--shadow-color);
        text-shadow: 0 1px 1px rgba(0, 0, 0, 0.1);
        color: #fff;
        font-weight: bold;
        animation: 0.3s ease;
        animation-name: flash-message-in;
        pointer-events: all;
      }
      .flash.is-exiting {
        animation: 0.3s forwards ease-in-out;
        animation-name: flash-message-out;
      }

      .flash[data-type='success'] {
        background: var(--color-green);
      }
      .flash[data-type='success'] .icon {
        opacity: 0.7;
        stroke: var(--color-green);
      }

      .flash[data-type='socket'] {
        background: var(--color-socket);
      }
      .flash[data-type='socket'] .icon {
        opacity: 0.7;
        stroke: var(--color-socket);
      }

      .flash[data-type='error'] {
        background: var(--color-error);
      }
      .flash[data-type='error'] .icon {
        opacity: 0.7;
        stroke: var(--color-error);
      }

      .content {
        display: flex;
        align-items: flex-start;
        padding: 15px 25px 15px 15px;
      }

      .text {
        flex: 1 1 auto;
        margin-top: 2px;
        line-height: 1.4;
        font-size: 11px;
      }

      .icon {
        width: 20px;
        height: 20px;
        margin-right: 14px;
      }

      .deleteButton {
        position: absolute;
        top: 6px;
        right: 0;
        background: none;
        text-align: center;
      }
      .deleteButton:focus {
        outline: none;
      }
      .deleteButton:focus .deleteButton-icon {
        stroke: #fff;
      }

      .deleteButton-icon {
        width: 13px;
        height: 13px;
        stroke: rgba(255, 255, 255, 0.6);
      }

      @keyframes flash-message-in {
        0% {
          margin-top: -30px;
          opacity: 0;
        }
        100% {
          margin-top: 0;
          opacity: 1;
        }
      }
      @keyframes flash-message-out {
        0% {
          margin-top: 0;
          opacity: 1;
        }
        100% {
          margin-top: -30px;
          opacity: 0;
        }
      }
    </style>
  </template>
  @readOnly('args.flash.exiting')
  isExiting: boolean;

  @readOnly('args.flash.type')
  type: 'info' | 'success' | 'error' | 'socket';

  get hasIcon() {
    return this.isSuccess || this.isError || this.isSocket;
  }

  get isSuccess() {
    return this.type === 'success';
  }

  get isError() {
    return this.type === 'error';
  }

  get isSocket() {
    return this.type === 'socket';
  }

  @action
  close() {
    const flash = this.args.flash;

    if (flash) flash.destroyMessage();
  }
}
