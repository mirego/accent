import Component from '@glimmer/component';
import {action} from '@ember/object';
import {readOnly} from '@ember/object/computed';
import {on} from '@ember/modifier';
import {fn} from '@ember/helper';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
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
        {{inlineSvg 'assets/x.svg' class=(scopedClass 'deleteButton-icon')}}
      </button>

      <div class='content'>
        {{#if this.iconPath}}
          <div class='icon'>
            {{inlineSvg this.iconPath}}
          </div>
        {{/if}}
        <p class='text'>
          {{@flash.message}}
        </p>
      </div>
    </div>
  </template>
  @readOnly('args.flash.exiting')
  isExiting: boolean;

  @readOnly('args.flash.type')
  type: 'info' | 'success' | 'error' | 'socket';

  get iconPath() {
    switch (this.type) {
      case 'success':
        return 'assets/check.svg';
      case 'error':
        return 'assets/x.svg';
      case 'socket':
        return 'assets/activity.svg';
      default:
        return null;
    }
  }

  @action
  close() {
    const flash = this.args.flash;

    if (flash) flash.destroyMessage();
  }
}
