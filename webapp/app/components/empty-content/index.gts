import Component from '@glimmer/component';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import {scopedClass} from 'ember-scoped-css';

interface Args {
  success?: boolean;
  center?: boolean;
  background?: string;
  text: string;
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
        {{#if @iconPath}}
          {{inlineSvg @iconPath class=(scopedClass 'icon')}}
        {{/if}}
        {{@text}}
      {{/if}}
    </div>
  </template>
  get isBackgroundPrimary() {
    return this.args.background === 'primary';
  }
}
