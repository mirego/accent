import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import BackLink from 'accent-webapp/components/project-settings/back-link/index';
import LoadingContent from 'accent-webapp/components/loading-content/index';
import t from 'ember-intl/helpers/t';
import ApiToken from 'accent-webapp/components/project-settings/api-token/index';
import {fn} from '@ember/helper';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <BackLink @project={{@controller.project}} />

    {{#if @controller.showLoading}}
      <LoadingContent
        @label={{t 'pods.project.edit.api_token.loading_content'}}
      />
    {{else}}
      <ApiToken
        @projectTokens={{@controller.project.apiTokens}}
        @permissions={{@controller.permissions}}
        @userToken={{@controller.accessToken}}
        @onCreate={{fn @controller.createApiToken}}
        @onRevoke={{fn @controller.revokeApiToken}}
      />
    {{/if}}
  </template>
);
