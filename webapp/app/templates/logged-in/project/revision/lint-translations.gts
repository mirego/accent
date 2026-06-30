import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import LintOptions from 'accent-webapp/components/lint-options/index';
import {fn} from '@ember/helper';
import ConflictsItems from 'accent-webapp/components/skeleton-ui/conflicts-items/index';
import ProgressLine from 'accent-webapp/components/skeleton-ui/progress-line/index';
import LintTranslationsPage from 'accent-webapp/components/lint-translations-page/index';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <LintOptions
      @documents={{@controller.model.documents.entries}}
      @document={{@controller.documentFilter}}
      @version={{@controller.versionFilter}}
      @versions={{@controller.model.versions.entries}}
      @query={{@controller.query}}
      @onChangeDocument={{fn (mut @controller.documentFilter)}}
      @onChangeVersion={{fn (mut @controller.versionFilter)}}
      @onChangeQuery={{fn (mut @controller.query)}}
    />
    {{#if @controller.showSkeleton}}
      <ConflictsItems />
    {{else}}
      {{#if @controller.model.loading}}
        <ProgressLine />
      {{/if}}

      <LintTranslationsPage
        @project={{@controller.model.project}}
        @lintTranslations={{@controller.model.lintTranslations}}
        @lintChecks={{@controller.model.lintChecks}}
        @permissions={{@controller.permissions}}
        @checkFilter={{@controller.checkFilter}}
        @revisionId={{@controller.revisionId}}
        @query={{@controller.query}}
        @onChangeCheckFilter={{@controller.changeCheckFilter}}
      />
    {{/if}}
  </template>
);
