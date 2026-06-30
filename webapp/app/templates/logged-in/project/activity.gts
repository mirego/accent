import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import LoadingContent from 'accent-webapp/components/loading-content/index';
import t from 'ember-intl/helpers/t';
import ProjectActivity from 'accent-webapp/components/project-activity/index';
import {fn} from '@ember/helper';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    {{#if @controller.model.loading}}
      <LoadingContent
        @label={{t 'pods.project.activities.show.loading_content'}}
      />
    {{else}}
      <ProjectActivity
        @permissions={{@controller.permissions}}
        @showTranslationLink={{true}}
        @componentTranslationPrefix='project_activities_list_item'
        @project={{@controller.model.project}}
        @activity={{@controller.model.activity}}
        @onRollback={{fn @controller.rollback}}
      />
    {{/if}}
  </template>
);
