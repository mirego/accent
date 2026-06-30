import Component from '@glimmer/component';

interface Args {
  link?: boolean;
  primary?: boolean;
  version?: boolean;
  danger?: boolean;
}

export default class Badge extends Component<Args> {
  <template>
    <div
      ...attributes
      class='badge
        {{if @version "version"}}
        {{if @icon "icon"}}
        {{if @link "link"}}
        {{if @warning "warning"}}
        {{if @primary "primary"}}
        {{if @danger "danger"}}'
    >
      {{yield}}
    </div>
  </template>
}
