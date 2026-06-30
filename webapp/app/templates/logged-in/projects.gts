import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import Projects from 'accent-webapp/components/acc-wrapper/projects/index';
import ProjectsHeader from 'accent-webapp/components/projects-header/index';
import ProjectsFilters from 'accent-webapp/components/projects-filters/index';
import {fn} from '@ember/helper';
import LoadingContent from 'accent-webapp/components/loading-content/index';
import t from 'ember-intl/helpers/t';
import RecentProjectsList from 'accent-webapp/components/recent-projects-list/index';
import ProjectsList from 'accent-webapp/components/projects-list/index';
import ResourcePagination from 'accent-webapp/components/resource-pagination/index';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <Projects>
      <ProjectsHeader @session={{@controller.session}} />
      <ProjectsFilters
        @permissions={{@controller.permissions}}
        @query={{@controller.query}}
        @onChangeQuery={{fn @controller.changeQuery}}
      />

      {{#if @controller.showLoading}}
        <LoadingContent @label={{t 'pods.projects.loading_content'}} />
      {{else}}
        <RecentProjectsList
          @permissions={{@controller.permissions}}
          @projects={{@controller.model.recentProjects}}
        />
        <ProjectsList
          @permissions={{@controller.permissions}}
          @projects={{@controller.model.projects.entries}}
          @query={{@controller.query}}
        />
        <ResourcePagination
          @meta={{@controller.model.projects.meta}}
          @onSelectPage={{fn @controller.selectPage}}
        />
      {{/if}}

      {{outlet}}
    </Projects>
  </template>
);
