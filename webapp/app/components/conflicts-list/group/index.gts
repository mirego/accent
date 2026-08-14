import {action} from '@ember/object';
import Component from '@glimmer/component';
import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';
import {LinkTo} from '@ember/routing';
import {array} from '@ember/helper';
import Item from 'accent-webapp/components/conflicts-list/item/index';

interface Args {
  selectedTranslationId: string | null;
  groupedTranslation: {
    key: string;
    translations: any[];
  };
  onFocus: (id: string) => void;
}

export default class ConflictsListGroup extends Component<Args> {
  <template>
    <li class='item {{if this.isFocused "item--focus"}}'>
      <LinkTo
        @route='logged-in.project.translation'
        @models={{array @project.id this.masterTranslation.id}}
        tabindex='-1'
        class='item-key'
      >
        {{this.translationKey.value}}

        <small class='item-key-prefix'>
          {{#if this.translationKey.prefix}}
            {{this.translationKey.prefix}}
          {{else}}
            {{@groupedTranslation.document.path}}
          {{/if}}
        </small>
      </LinkTo>

      <ul class='item-grid'>
        {{#each @groupedTranslation.translations key='id' as |translation|}}
          <li
            class='item-grid-item
              {{if translation.isTranslated "item-grid-item--translated"}}
              {{if
                translation.isConflicted
                "item-grid-item--conflicted"
                "item-grid-item--reviewed"
              }}'
          >
            <Item
              @permissions={{@permissions}}
              @project={{@project}}
              @prompts={{@prompts}}
              @translation={{translation}}
              @onCorrect={{@onCorrect}}
              @onUncorrect={{@onUncorrect}}
              @onUpdate={{@onUpdate}}
              @isFocused={{this.isFocused}}
              @onFocus={{this.handleFocus}}
            />
          </li>
        {{/each}}
      </ul>
    </li>

    <style scoped>
      .item {
        --grid-item-reviewed-opacity: 0.5;
        --grid-item-actions-opacity: 0;
        border-bottom: 1px solid var(--background-light-highlight);
        transition: 0.2s ease-in-out;
        transition-property: border-color;
        background: var(--content-background);
      }
      .item :global(.lint-translations-item) {
        display: none;
        padding: 2px 6px;
        border-radius: var(--border-radius);
        margin: 0 5px 5px;
        background: var(--background-light);
      }
      .item.item--focus {
        background: var(--background-light);
      }
      .item.item--focus :global(.lint-translations-item) {
        display: block;
      }
      .item.item--focus .item-key {
        transform: translateY(2px);
      }
      .item.item--focus {
        --grid-item-reviewed-opacity: 1;
        --grid-item-actions-opacity: 1;
      }

      .item-grid {
        display: grid;
        grid-template-columns: repeat(var(--group-columns-count, 1), 1fr);
      }

      .item-grid-item {
        --border-color: var(--background-light-highlight);
        min-width: var(--group-columns-width);
        position: relative;
        padding: 0;
        border-left: 2px solid var(--border-color);
        opacity: 1;
      }
      .item-grid-item.item-grid-item--translated {
        --border-color: var(--color-warning);
        opacity: 1;
      }
      .item-grid-item.item-grid-item--reviewed {
        --border-color: var(--color-green);
        opacity: var(--grid-item-reviewed-opacity);
      }
      .item-grid-item:hover {
        opacity: 1;
      }
      .item-grid-item::before {
        position: absolute;
        content: '';
        top: -24px;
        left: -2px;
        height: 32px;
        width: 2px;
        background: var(--border-color);
      }

      .item-key-prefix {
        display: inline-flex;
        font-size: 11px;
        color: #959595;
        gap: 6px;
        font-weight: 300;
        flex-shrink: 0;
      }
      .item-key-prefix::before {
        content: '/';
      }

      .item-key {
        position: sticky;
        top: 46px;
        left: 0;
        display: inline-flex;
        align-items: flex-start;
        gap: 5px;
        background: var(--content-background);
        padding: 2px 6px;
        text-decoration: none;
        font-family: var(--font-monospace);
        box-shadow: 0 2px 4px var(--shadow-color);
        border-radius: var(--border-radius);
        font-weight: 600;
        z-index: 2;
        word-break: break-all;
        transition: 0.2s ease-in-out;
        transition-property: color;
        margin-left: 4px;
        line-height: 1.5;
        font-size: 11px;
        color: var(--text-color-normal);
        transition: 0.2s ease-in-out;
        transition-property: transform;
      }

      .key {
        text-decoration: none;
      }
    </style>
  </template>
  translationKey = parsedKeyProperty(this.args.groupedTranslation.key);

  get masterTranslation() {
    return this.args.groupedTranslation.translations[0];
  }

  get isFocused() {
    return this.masterTranslation.id === this.args.selectedTranslationId;
  }

  @action
  handleFocus() {
    this.args.onFocus(this.masterTranslation.id);
  }
}
