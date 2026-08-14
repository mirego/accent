import Component from '@glimmer/component';
import ActivitySvg from 'accent-webapp/svgs/assets/activity.svg';
import IntegrationLogo from 'accent-webapp/components/integration-logo/index';
import {scopedClass} from 'ember-scoped-css';
import t from 'ember-intl/helpers/t';
import timeAgoInWords from 'accent-webapp/helpers/time-ago-in-words';
import Item from 'accent-webapp/components/integration-executions-list/item/index';
import EmptyContent from 'accent-webapp/components/empty-content/index';

interface Args {
  integration: any;
  executions: any[];
}

export default class IntegrationExecutionsList extends Component<Args> {
  <template>
    {{#if @integration}}
      <div class='header'>
        <div class='header-info'>
          <IntegrationLogo
            @service={{@integration.service}}
            class={{scopedClass 'header-logo'}}
          />
          <span class='header-service'>
            {{t this.mappedServiceTranslationKey}}
          </span>

          <span class='header-preview'>
            {{@integration.data.url}}
            {{@integration.data.sasBaseUrl}}
            {{@integration.data.accessKeyId}}
            {{@integration.data.bucket}}
            {{@integration.data.pathPrefix}}

            {{#if @integration.lastIntegrationExecution}}
              <span class='header-last-executed-at'>{{t
                  'components.project_settings.integrations.last_executed_at'
                }}
                {{timeAgoInWords
                  @integration.lastIntegrationExecution.insertedAt
                }}</span>
            {{/if}}
          </span>
        </div>
      </div>
    {{/if}}

    {{#if @executions}}
      <ul class='list'>
        {{#each @executions key='id' as |execution|}}
          <Item @execution={{execution}} />
        {{/each}}
      </ul>
    {{else}}
      <div class='empty'>
        <EmptyContent
          @center={{true}}
          @icon={{ActivitySvg}}
          @text={{t 'components.integration_executions.empty'}}
        />
      </div>
    {{/if}}

    <style scoped>
      .header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 10px 15px;
        margin-top: 35px;
        border: 1px solid var(--background-light-highlight);
        border-radius: var(--border-radius);
      }

      .header-info {
        display: flex;
        align-items: center;
        overflow-x: hidden;
        flex: 1 1 auto;
      }

      .header-logo {
        flex: 0 0 20px;
        margin-right: 8px;
        width: 20px;
      }

      .header-service {
        font-size: 13px;
        font-weight: bold;
        color: var(--color-black);
      }

      .header-preview {
        padding-right: 15px;
        text-overflow: ellipsis;
        overflow-x: hidden;
        margin-left: 10px;
        font-size: 13px;
        color: var(--color-black);
      }

      .header-last-executed-at {
        margin-left: 5px;
        font-size: 11px;
        opacity: 0.4;
      }

      .list {
        list-style: none;
        padding: 0;
        margin: 15px 0 0;
      }

      .empty {
        margin: 15px 0 0;
      }
    </style>
  </template>
  get mappedServiceTranslationKey() {
    return `general.integration_services.${this.args.integration?.service}`;
  }
}
