import Component from '@glimmer/component';

interface Args {
  label?: string;
}

export default class LoadingContent extends Component<Args> {
  <template>
    <div data-test-loader ...attributes class='loading-content'>
      <svg viewBox='25 25 50 50'>
        <circle cx='50' cy='50' r='20'></circle>
      </svg>

      {{#if @label}}
        <span class='label'>{{@label}}</span>
      {{/if}}
    </div>
  </template>
}
