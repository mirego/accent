import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import ProgressLine from 'accent-webapp/components/skeleton-ui/progress-line/index';
import LoadingContent from 'accent-webapp/components/loading-content/index';
import t from 'ember-intl/helpers/t';
import DashboardRevisions from 'accent-webapp/components/dashboard-revisions/index';
import {fn} from '@ember/helper';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    {{#if @controller.model.loading}}
      <ProgressLine />
    {{/if}}

    {{#if @controller.showLoading}}
      <LoadingContent @label={{t 'pods.project.index.loading_content'}} />
    {{else}}
      <DashboardRevisions
        @document={{@controller.selectedDocument}}
        @project={{@controller.project}}
        @revisions={{@controller.revisions}}
        @mainRevisions={{@controller.mainRevisions}}
        @permissions={{@controller.permissions}}
        @documents={{@controller.documents}}
        @versions={{@controller.versions}}
        @selectedDocument={{@controller.document}}
        @selectedVersion={{@controller.version}}
        @showDocumentsSelect={{@controller.showDocumentsSelect}}
        @showVersionsSelect={{@controller.showVersionsSelect}}
        @onChangeDocument={{fn @controller.changeDocument}}
        @onChangeVersion={{fn @controller.changeVersion}}
        @onCorrectAllConflicts={{fn @controller.correctAllConflicts}}
        @onUncorrectAllConflicts={{fn @controller.uncorrectAllConflicts}}
        @onCorrectAllConflictsFromVersion={{fn
          @controller.correctAllConflictsFromVersion
        }}
      />
    {{/if}}
  </template>
);
