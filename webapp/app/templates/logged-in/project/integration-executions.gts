import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import {LinkTo} from '@ember/routing';
import t from 'ember-intl/helpers/t';
import ProgressLine from 'accent-webapp/components/skeleton-ui/progress-line/index';
import LoadingContent from 'accent-webapp/components/loading-content/index';
import IntegrationExecutionsList from 'accent-webapp/components/integration-executions-list/index';
import ResourcePagination from 'accent-webapp/components/resource-pagination/index';
import {fn} from '@ember/helper';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <LinkTo
      @route='logged-in.project.service-integrations'
      class='button button--borderless button--primary'
    >
      {{t 'components.integration_executions.back_link'}}
    </LinkTo>

    {{#if @controller.model.loading}}
      <ProgressLine />
    {{/if}}

    {{#if @controller.showSkeleton}}
      <LoadingContent
        @label={{t 'components.integration_executions.loading_content'}}
      />
    {{else}}
      <IntegrationExecutionsList
        @integration={{@controller.model.integration}}
        @executions={{@controller.model.executions.entries}}
      />
      <ResourcePagination
        @meta={{@controller.model.executions.meta}}
        @onSelectPage={{fn @controller.selectPage}}
      />
    {{/if}}
  </template>
);
