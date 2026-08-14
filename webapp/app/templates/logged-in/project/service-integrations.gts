import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import PageTitle from 'accent-webapp/components/page-title/index';
import ShareSvg from 'accent-webapp/svgs/assets/share.svg';
import t from 'ember-intl/helpers/t';
import End from 'accent-webapp/components/page-title/end/index';
import {get, fn} from '@ember/helper';
import IntegrationsAddButton from 'accent-webapp/components/integrations-add-button/index';
import LoadingContent from 'accent-webapp/components/loading-content/index';
import Integrations from 'accent-webapp/components/project-settings/integrations/index';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <PageTitle>
      <ShareSvg />
      <h1>{{t 'components.page_title.service_integrations'}}</h1>
      <End>
        {{#if (get @controller.permissions 'createProjectIntegration')}}
          {{#unless @controller.showCreateForm}}
            <IntegrationsAddButton
              @onClick={{fn @controller.toggleCreateForm}}
            />
          {{/unless}}
        {{/if}}
      </End>
    </PageTitle>

    {{#if @controller.showLoading}}
      <LoadingContent
        @label={{t 'pods.project.edit.service_integrations.loading_content'}}
      />
    {{else}}
      <Integrations
        @project={{@controller.project}}
        @permissions={{@controller.permissions}}
        @showCreateForm={{@controller.showCreateForm}}
        @onToggleCreateForm={{fn @controller.toggleCreateForm}}
        @onCreateIntegration={{fn @controller.createIntegration}}
        @onUpdateIntegration={{fn @controller.updateIntegration}}
        @onDeleteIntegration={{fn @controller.deleteIntegration}}
      />
    {{/if}}
  </template>
);
