import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import PageTitle from 'accent-webapp/components/page-title/index';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import t from 'ember-intl/helpers/t';
import ProgressLine from 'accent-webapp/components/skeleton-ui/progress-line/index';
import LoadingContent from 'accent-webapp/components/loading-content/index';
import Collaborators from 'accent-webapp/components/project-settings/collaborators/index';
import {fn} from '@ember/helper';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <PageTitle>
      {{inlineSvg '/assets/users.svg'}}
      <h1>{{t 'components.page_title.collaborators'}}</h1>
    </PageTitle>

    {{#if @controller.model.loading}}
      <ProgressLine />
    {{/if}}

    {{#if @controller.showLoading}}
      <LoadingContent
        @label={{t 'pods.project.collaborators.loading_content'}}
      />
    {{else}}
      <Collaborators
        @project={{@controller.project}}
        @permissions={{@controller.permissions}}
        @collaborators={{@controller.collaborators}}
        @onCreateCollaborator={{fn @controller.createCollaborator}}
        @onUpdateCollaborator={{fn @controller.updateCollaborator}}
        @onDeleteCollaborator={{fn @controller.deleteCollaborator}}
      />
    {{/if}}
  </template>
);
