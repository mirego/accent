import Component from '@glimmer/component';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import integrationLogo from 'accent-webapp/helpers/integration-logo';
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
          {{inlineSvg
            (integrationLogo @integration.service)
            class=(scopedClass 'header-logo')
          }}
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
          @iconPath='assets/activity.svg'
          @text={{t 'components.integration_executions.empty'}}
        />
      </div>
    {{/if}}
  </template>
  get mappedServiceTranslationKey() {
    return `general.integration_services.${this.args.integration?.service}`;
  }
}
