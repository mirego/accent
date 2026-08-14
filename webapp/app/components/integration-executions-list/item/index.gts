import Component from '@glimmer/component';
import TimeAgoInWordsTag from 'accent-webapp/components/time-ago-in-words-tag/index';
import t from 'ember-intl/helpers/t';
import HighlightRender from 'accent-webapp/components/highlight-render/index';

interface Args {
  execution: {
    id: string;
    state: string;
    data: any;
    results: any;
    insertedAt: string;
    user: {
      id: string;
      email: string;
      fullname: string;
      pictureUrl: string;
    };
    version?: {
      id: string;
      tag: string;
    };
  };
}

export default class IntegrationExecutionsListItem extends Component<Args> {
  <template>
    <li class='item'>
      <div class='item-header'>
        <span
          class='state {{if this.isSuccess "state--success" "state--error"}}'
        >
          {{@execution.state}}
        </span>

        <span class='date'>
          <TimeAgoInWordsTag @date={{@execution.insertedAt}} />
        </span>

        {{#if @execution.user}}
          <span class='user'>
            {{#if @execution.user.fullname}}
              {{@execution.user.fullname}}
            {{else}}
              {{@execution.user.email}}
            {{/if}}
          </span>
        {{/if}}

        {{#if @execution.version}}
          <span class='version'>
            {{@execution.version.tag}}
          </span>
        {{/if}}
      </div>

      {{#if this.formattedData}}
        <div class='json-block'>
          <span class='json-label'>{{t
              'components.integration_executions.data_label'
            }}</span>
          <HighlightRender
            @content={{this.formattedData}}
            @language='json'
            class='json-content'
          />
        </div>
      {{/if}}

      {{#if this.formattedResults}}
        <div class='json-block'>
          <span class='json-label'>{{t
              'components.integration_executions.results_label'
            }}</span>
          <HighlightRender
            @content={{this.formattedResults}}
            @language='json'
            class='json-content'
          />
        </div>
      {{/if}}
    </li>

    <style scoped>
      .item {
        padding: 15px;
        border: 1px solid var(--background-light-highlight);
        border-radius: var(--border-radius);
        margin-bottom: 10px;
      }

      .item-header {
        display: flex;
        align-items: center;
        gap: 12px;
      }

      .state {
        font-size: 12px;
        font-weight: bold;
        text-transform: uppercase;
        padding: 2px 8px;
        border-radius: var(--border-radius);
        background: var(--background-light-highlight);
        color: var(--color-black);
      }

      .state--success {
        background: var(--color-success);
        color: #fff;
      }

      .state--error {
        background: var(--color-error);
        color: #fff;
      }

      .date {
        font-size: 13px;
        color: var(--color-black);
        opacity: 0.6;
      }

      .user {
        font-size: 13px;
        color: var(--color-black);
      }

      .version {
        font-size: 12px;
        padding: 2px 6px;
        border-radius: var(--border-radius);
        background: var(--background-light-highlight);
        color: var(--color-black);
      }

      .json-block {
        margin-top: 8px;
      }

      .json-label {
        display: block;
        font-size: 11px;
        font-weight: bold;
        text-transform: uppercase;
        color: var(--color-black);
        opacity: 0.5;
        margin-bottom: 4px;
      }

      .json-content {
        --highlight-render-height: auto;
        font-family: monospace;
        font-size: 12px;
        border-radius: var(--border-radius);
        background: var(--background-light);
      }
    </style>
  </template>
  get formattedData() {
    if (!this.args.execution.data) return null;
    return JSON.stringify(this.args.execution.data, null, 2);
  }

  get formattedResults() {
    if (!this.args.execution.results) return null;
    return JSON.stringify(this.args.execution.results, null, 2);
  }

  get isSuccess() {
    return this.args.execution.state === 'SUCCESS';
  }
}
