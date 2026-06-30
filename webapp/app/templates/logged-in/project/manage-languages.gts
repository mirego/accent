import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import PageTitle from 'accent-webapp/components/page-title/index';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import t from 'ember-intl/helpers/t';
import ProgressLine from 'accent-webapp/components/skeleton-ui/progress-line/index';
import LoadingContent from 'accent-webapp/components/loading-content/index';
import ManageLanguages from 'accent-webapp/components/project-settings/manage-languages/index';
import {fn} from '@ember/helper';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <PageTitle>
      {{inlineSvg '/assets/language.svg'}}
      <h1>{{t 'components.page_title.manage_languages'}}</h1>
    </PageTitle>

    {{#if @controller.model.loading}}
      <ProgressLine />
    {{/if}}

    {{#if @controller.showLoading}}
      <LoadingContent
        @label={{t 'pods.project.manage_languages.loading_content'}}
      />
    {{else}}
      <ManageLanguages
        @project={{@controller.model.project}}
        @revisions={{@controller.model.project.revisions}}
        @permissions={{@controller.permissions}}
        @languages={{@controller.filteredLanguages}}
        @errors={{@controller.errors}}
        @onPromoteMaster={{fn @controller.promoteRevisionMaster}}
        @onDelete={{fn @controller.deleteRevision}}
        @onCreate={{fn @controller.create}}
      />
    {{/if}}

    {{outlet}}
  </template>
);
