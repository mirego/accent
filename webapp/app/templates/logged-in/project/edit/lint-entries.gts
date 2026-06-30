import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import BackLink from 'accent-webapp/components/project-settings/back-link/index';
import LoadingContent from 'accent-webapp/components/loading-content/index';
import t from 'ember-intl/helpers/t';
import LintEntries from 'accent-webapp/components/project-settings/lint-entries/index';
import ResourcePagination from 'accent-webapp/components/resource-pagination/index';
import {fn} from '@ember/helper';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <BackLink @project={{@controller.project}} />

    {{#if @controller.showLoading}}
      <LoadingContent
        @label={{t 'pods.project.edit.lint_entries.loading_content'}}
      />
    {{else}}
      <LintEntries
        @lintEntries={{@controller.lintEntries}}
        @permissions={{@controller.permissions}}
        @onCreate={{@controller.createLintEntry}}
        @onUpdate={{@controller.updateLintEntry}}
        @onDelete={{@controller.deleteLintEntry}}
      />

      <ResourcePagination
        @meta={{@controller.lintEntries.meta}}
        @onSelectPage={{fn @controller.selectPage}}
      />

      {{outlet}}
    {{/if}}
  </template>
);
