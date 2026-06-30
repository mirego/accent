import Component from '@glimmer/component';
import {action} from '@ember/object';
import {on} from '@ember/modifier';
import {fn} from '@ember/helper';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
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

        {{inlineSvg '/assets/loading.svg' class=(scopedClass 'loading')}}
      </div>
    </button>
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
