import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import BackLink from 'accent-webapp/components/project-settings/back-link/index';
import LoadingContent from 'accent-webapp/components/loading-content/index';
import t from 'ember-intl/helpers/t';
import Cli from 'accent-webapp/components/project-settings/cli/index';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <BackLink @project={{@controller.project}} />

    {{#if @controller.showLoading}}
      <LoadingContent @label={{t 'pods.project.edit.cli.loading_content'}} />
    {{else}}
      <Cli @project={{@controller.project}} />
    {{/if}}
  </template>
);
