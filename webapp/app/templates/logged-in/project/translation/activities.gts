import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import ProgressLine from 'accent-webapp/components/skeleton-ui/progress-line/index';
import ActivitiesList from 'accent-webapp/components/skeleton-ui/activities-list/index';
import TranslationActivitiesList from 'accent-webapp/components/translation-activities-list/index';
import ResourcePagination from 'accent-webapp/components/resource-pagination/index';
import {fn} from '@ember/helper';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    {{#if @controller.model.loading}}
      <ProgressLine />
    {{/if}}

    {{#if @controller.showSkeleton}}
      <ActivitiesList @showTranslationLink={{false}} />
    {{else}}
      <TranslationActivitiesList
        @permissions={{@controller.permissions}}
        @project={{@controller.model.project}}
        @activities={{@controller.model.activities.entries}}
      />
      <ResourcePagination
        @meta={{@controller.model.activities.meta}}
        @onSelectPage={{fn @controller.selectPage}}
      />
    {{/if}}
  </template>
);
