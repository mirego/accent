import Component from '@glimmer/component';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import {scopedClass} from 'ember-scoped-css';

interface Args {
  title: string;
}

export default class Title extends Component<Args> {
  <template>
    <h2 class='project-settings-title'>
      {{#if @icon}}
        {{inlineSvg @icon class=(scopedClass 'icon')}}
      {{/if}}

      {{@title}}
    </h2>
  </template>
}
