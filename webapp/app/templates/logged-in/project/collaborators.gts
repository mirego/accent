import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import PageTitle from 'accent-webapp/components/page-title/index';
import UsersSvg from 'accent-webapp/svgs/assets/users.svg';
import t from 'ember-intl/helpers/t';
import ProgressLine from 'accent-webapp/components/skeleton-ui/progress-line/index';
import CollaboratorsSkeleton from 'accent-webapp/components/skeleton-ui/collaborators/index';
import Collaborators from 'accent-webapp/components/project-settings/collaborators/index';
import {fn} from '@ember/helper';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <PageTitle>
      <UsersSvg />
      <h1>{{t 'components.page_title.collaborators'}}</h1>
    </PageTitle>

    {{#if @controller.model.loading}}
      <ProgressLine />
    {{/if}}

    {{#if @controller.showLoading}}
      <CollaboratorsSkeleton />
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
