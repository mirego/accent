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

    <style scoped>
      .badge {
        transition: 0.2s ease-in-out;
        transition-property: background;
        display: inline-flex;
        align-items: center;
        padding: 1px 6px 1px 5px;
        background: var(--background-light);
        border-radius: var(--border-radius);
        color: #949494;
        font-size: 11px;
        font-weight: 600;
        text-transform: capitalize;
        text-decoration: none;
      }

      .primary {
        background: var(--color-primary);
        color: #fff;
      }

      .version {
        font-family: var(--font-monospace);
        background: var(--content-background);
        border: 1px solid var(--input-border-color);
        text-transform: none;
        box-shadow: 0 1px 2px var(--shadow-color);
      }

      .warning {
        color: var(--color-warning);
      }

      .danger {
        background: var(--color-error);
        color: #fff;
      }

      .icon {
        background: transparent;
      }
      .icon :global(svg) {
        height: 12px;
      }

      .link {
        padding: 0;
      }
      .link:focus,
      .link:hover {
        background: var(--background-light-highlight);
      }

      .link.primary {
        padding: 0;
      }
      .link.primary:focus,
      .link.primary:hover {
        background: hsl(from var(--color-primary) h 55% 40%);
      }

      .link :global(a) {
        display: inline-block;
        padding: 1px 6px 1px 5px;
        color: #949494;
        text-decoration: none;
      }

      .link.primary :global(a) {
        color: #fff;
      }
    </style>
  </template>
}
