import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import PageTitle from 'accent-webapp/components/page-title/index';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import t from 'ember-intl/helpers/t';
import End from 'accent-webapp/components/page-title/end/index';
import {get, fn} from '@ember/helper';
import VersionsAddButton from 'accent-webapp/components/versions-add-button/index';
import ProgressLine from 'accent-webapp/components/skeleton-ui/progress-line/index';
import VersionsListSkeleton from 'accent-webapp/components/skeleton-ui/versions-list/index';
import VersionsList from 'accent-webapp/components/versions-list/index';
import ResourcePagination from 'accent-webapp/components/resource-pagination/index';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <PageTitle>
      {{inlineSvg '/assets/tag.svg'}}
      <h1>{{t 'components.page_title.versions'}}</h1>
      <End>
        {{#if @controller.model.versions.entries.length}}
          {{#if (get @controller.permissions 'createVersion')}}
            <VersionsAddButton @project={{@controller.model.project}} />
          {{/if}}
        {{/if}}

      </End>
    </PageTitle>

    {{#if @controller.model.loading}}
      <ProgressLine />
    {{/if}}

    {{#if @controller.showSkeleton}}
      <VersionsListSkeleton />
    {{else}}
      <VersionsList
        @permissions={{@controller.permissions}}
        @versions={{@controller.model.versions.entries}}
        @project={{@controller.model.project}}
        @onDelete={{fn @controller.deleteVersion}}
      />

      {{#if (get @controller.permissions 'createVersion')}}
        <VersionsAddButton @project={{@controller.model.project}} />
      {{/if}}

      <ResourcePagination
        @meta={{@controller.model.versions.meta}}
        @onSelectPage={{fn @controller.selectPage}}
      />
      {{outlet}}
    {{/if}}
  </template>
);
