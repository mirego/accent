import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import PageTitle from 'accent-webapp/components/page-title/index';
import BubbleSvg from 'accent-webapp/svgs/assets/bubble.svg';
import t from 'ember-intl/helpers/t';
import ProgressLine from 'accent-webapp/components/skeleton-ui/progress-line/index';
import ProjectCommentsListSkeleton from 'accent-webapp/components/skeleton-ui/project-comments-list/index';
import ProjectCommentsList from 'accent-webapp/components/project-comments-list/index';
import {fn} from '@ember/helper';
import ResourcePagination from 'accent-webapp/components/resource-pagination/index';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <PageTitle>
      <BubbleSvg />
      <h1>{{t 'components.page_title.comments'}}</h1>
    </PageTitle>

    {{#if @controller.model.loading}}
      <ProgressLine />
    {{/if}}

    {{#if @controller.showSkeleton}}
      <ProjectCommentsListSkeleton />
    {{else}}
      <ProjectCommentsList
        @project={{@controller.model.project}}
        @comments={{@controller.model.comments.entries}}
        @onUpdateComment={{fn @controller.updateComment}}
        @onDeleteComment={{fn @controller.deleteComment}}
      />
      <ResourcePagination
        @meta={{@controller.model.comments.meta}}
        @onSelectPage={{fn @controller.selectPage}}
      />
    {{/if}}
  </template>
);
