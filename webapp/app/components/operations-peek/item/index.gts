import Component from '@glimmer/component';
import {action} from '@ember/object';
import {tracked} from '@glimmer/tracking';
import t from 'ember-intl/helpers/t';
import {on} from '@ember/modifier';

interface Args {
  revisionOperation: any;
  shouldShowStats: boolean;
  shouldShowOperations: boolean;
  shouldHideDetails: boolean;
}

export default class OperationsPeekItem extends Component<Args> {
  <template>
    <div class='operations-peek-item'>
      {{#if @shouldShowStats}}
        <ul class='statsList'>
          {{#each @revisionOperation.stats as |stat|}}
            <li class='stat'>
              <span class='stat-count'>
                {{stat.count}}
              </span>

              <span class='stat-action'>
                {{stat.action}}
              </span>
            </li>
          {{else}}
            <li class='noChanges'>
              {{t 'components.operations_peek.item.empty_changes'}}
            </li>
          {{/each}}
        </ul>
      {{/if}}

      {{#if @shouldShowOperations}}
        <ul class='operationsList'>
          <input
            type='text'
            placeholder={{t
              'components.conflicts_filters.input_placeholder_text'
            }}
            class='input'
            {{on 'keyup' this.filterOperations}}
          />

          {{#each this.operations as |operation|}}
            <li class='operation'>
              <div class='operation-header'>
                <span class='operation-key'>
                  {{operation.key}}
                </span>
                <strong class='operation-action'>
                  {{operation.action}}
                </strong>
              </div>

              <div class='operation-content'>
                {{#if operation.previousText}}
                  {{#if operation.text}}
                    <div>
                      <span class='operation-textLabel'>
                        {{t 'components.operations_peek.item.previous_label'}}
                      </span>

                      <div
                        class='operation-text'
                      >{{operation.previousText}}</div>
                    </div>

                    <div>
                      <span class='operation-textLabel'>
                        {{t 'components.operations_peek.item.text_label'}}
                      </span>

                      <div class='operation-text'>{{operation.text}}</div>
                    </div>
                  {{else}}
                    <div class='operation-text'>{{operation.previousText}}</div>
                  {{/if}}
                {{else}}
                  <div class='operation-text'>{{operation.text}}</div>
                {{/if}}
              </div>
            </li>
          {{else}}
            {{#if this.searchQuery}}
              <li class='noChanges'>
                {{t 'components.operations_peek.item.empty_results'}}
              </li>
            {{else}}
              <li class='noChanges'>
                {{t 'components.operations_peek.item.empty_changes'}}
              </li>
            {{/if}}
          {{/each}}
        </ul>
      {{/if}}
    </div>

    <style scoped>
      .input {
        transition: 0.2s ease-in-out;
        transition-property: background, border, box-shadow;
        resize: vertical;
        outline: 0;
        border-radius: var(--border-radius);
        border: 2px solid var(--input-border-color);
        background: var(--input-background);
        color: var(--input-color);
        font-family: var(--font-monospace);
        line-height: 1.4;
        max-height: 200px;
      }
      .input::-moz-selection {
        background: color-mix(in srgb, var(--color-primary) 70%, transparent);
      }
      .input::selection {
        background: color-mix(in srgb, var(--color-primary) 70%, transparent);
      }
      .input:focus {
        border: 2px solid var(--color-primary);
      }
      .input:disabled {
        color: var(--color-grey);
        background: var(--background-light);
      }

      @media (hover: none) and (max-width: 640px) {
        .input {
          font-size: 16px !important;
        }
      }
      .operations-peek-item {
        margin-bottom: 15px;
      }

      .input {
        position: sticky;
        top: 0;
        width: 100%;
        padding: 5px 7px;
        font-family: var(--font-primary);
        font-size: 12px;
        color: var(--color-black);
      }
      .input:focus {
        box-shadow:
          inset 0 1px 2px rgba(0, 0, 0, 0.1),
          0 1px 2px var(--shadow-color);
      }
      .input::placeholder {
        color: var(--color-grey);
      }

      .statsList,
      .operationsList {
        max-height: 500px;
        overflow-y: auto;
        margin: 10px 0;
        background: var(--content-background);
        box-shadow: 0 2px 10px var(--shadow-color);
      }

      .stat {
        padding: 5px 10px;
      }
      .stat:first-of-type {
        padding-top: 10px;
      }
      .stat:last-of-type {
        padding-bottom: 10px;
        border-bottom-color: transparent;
      }

      .stat-count {
        margin-right: 6px;
        font-size: 16px;
        font-weight: bold;
      }

      .stat-action {
        font-size: 13px;
      }

      .operation-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 10px;
        background: var(--background-light);
      }

      .operation-content {
        padding: 5px 10px 10px;
      }

      .operation-action {
        font-size: 12px;
        color: var(--color-grey);
      }

      .operation-key {
        word-break: break-all;
        font-family: var(--font-monospace);
        font-size: 11px;
      }

      .operation-textLabel {
        margin-right: 5px;
        font-size: 12px;
        font-weight: bold;
      }

      .operation-text {
        display: inline-block;
        font-size: 12px;
      }

      .noChanges {
        padding: 20px 10px;
        font-style: italic;
        font-size: 12px;
        color: var(--color-grey);
      }
    </style>
  </template>
  @tracked
  searchQuery = '';

  get operations() {
    if (!this.searchQuery) return this.args.revisionOperation.operations;

    const query = new RegExp(this.searchQuery, 'i');

    return this.args.revisionOperation.operations.filter(
      (operation: {key: string; previousText: string; text: string}) => {
        return [operation.key, operation.previousText, operation.text].some(
          (text) => text.match(query)
        );
      }
    );
  }

  @action
  filterOperations(event: Event) {
    const target = event.target as HTMLInputElement;
    this.searchQuery = target.value;
  }
}
