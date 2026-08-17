import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import PageTitle from 'accent-webapp/components/page-title/index';
import ActivitySvg from 'accent-webapp/svgs/assets/activity.svg';
import t from 'ember-intl/helpers/t';
import ProjectActivitiesFilterSkeleton from 'accent-webapp/components/skeleton-ui/project-activities-filter/index';
import ProjectActivitiesFilter from 'accent-webapp/components/project-activities-filter/index';
import ProgressLine from 'accent-webapp/components/skeleton-ui/progress-line/index';
import ActivitiesList from 'accent-webapp/components/skeleton-ui/activities-list/index';
import {fn} from '@ember/helper';
import ProjectActivitiesList from 'accent-webapp/components/project-activities-list/index';
import ResourcePagination from 'accent-webapp/components/resource-pagination/index';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <PageTitle>
      <ActivitySvg />
      <h1>{{t 'components.page_title.activities'}}</h1>
    </PageTitle>

    {{#if @controller.showSkeleton}}
      <ProjectActivitiesFilterSkeleton />

      {{#if @controller.model.loading}}
        <ProgressLine />
      {{/if}}
      <ActivitiesList @showTranslationLink={{true}} />
    {{else}}
      {{#if @controller.model.collaborators}}
        <ProjectActivitiesFilter
          @versions={{@controller.model.versions}}
          @collaborators={{@controller.model.collaborators}}
          @batchFilter={{@controller.batchFilter}}
          @actionFilter={{@controller.actionFilter}}
          @userFilter={{@controller.userFilter}}
          @versionFilter={{@controller.versionFilter}}
          @userFilterChange={{fn @controller.userFilterChange}}
          @batchFilterChange={{fn @controller.batchFilterChange}}
          @actionFilterChange={{fn @controller.actionFilterChange}}
          @versionFilterChange={{fn @controller.versionFilterChange}}
        />
      {{/if}}

      {{#if @controller.model.loading}}
        <ProgressLine />
      {{/if}}

      <ProjectActivitiesList
        @permissions={{@controller.permissions}}
        @activities={{@controller.model.activities.entries}}
        @withFilters={{@controller.hasFilters}}
        @project={{@controller.model.project}}
      />

      <ResourcePagination
        @meta={{@controller.model.activities.meta}}
        @onSelectPage={{fn @controller.selectPage}}
      />
    {{/if}}
  </template>
);
