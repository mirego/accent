import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import PageTitle from 'accent-webapp/components/page-title/index';
import LanguageSvg from 'accent-webapp/svgs/assets/language.svg';
import t from 'ember-intl/helpers/t';
import ProgressLine from 'accent-webapp/components/skeleton-ui/progress-line/index';
import ManageLanguagesSkeleton from 'accent-webapp/components/skeleton-ui/manage-languages/index';
import ManageLanguages from 'accent-webapp/components/project-settings/manage-languages/index';
import {fn} from '@ember/helper';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <PageTitle>
      <LanguageSvg />
      <h1>{{t 'components.page_title.manage_languages'}}</h1>
    </PageTitle>

    {{#if @controller.model.loading}}
      <ProgressLine />
    {{/if}}

    {{#if @controller.showLoading}}
      <ManageLanguagesSkeleton />
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
