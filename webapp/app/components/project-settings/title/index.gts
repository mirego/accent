import Component from '@glimmer/component';
import {scopedClass} from 'ember-scoped-css';

interface Args {
  title: string;
  icon?: unknown;
}

export default class Title extends Component<Args> {
  <template>
    <h2 class='project-settings-title'>
      {{#if @icon}}
        <@icon class={{scopedClass 'icon'}} />
      {{/if}}

      {{@title}}
    </h2>

    <style scoped>
      .project-settings-title {
        display: flex;
        gap: 8px;
        align-items: center;
        font-size: 18px;
        font-weight: bold;
        color: var(--text-color-normal);
      }

      .icon {
        width: 14px;
        opacity: 0.8;
      }
    </style>
  </template>
}
