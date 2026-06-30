import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import ProgressLine from 'accent-webapp/components/skeleton-ui/progress-line/index';
import TranslationCommentsList from 'accent-webapp/components/skeleton-ui/translation-comments-list/index';
import TranslationConversation from 'accent-webapp/components/translation-conversation/index';
import {fn} from '@ember/helper';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    {{#if @controller.model.loading}}
      <ProgressLine />
    {{/if}}

    {{#if @controller.showSkeleton}}
      <TranslationCommentsList />
    {{else}}
      <TranslationConversation
        @permissions={{@controller.permissions}}
        @translation={{@controller.model.translation}}
        @collaborators={{@controller.model.collaborators}}
        @subscriptions={{@controller.model.commentsSubscriptions}}
        @comments={{@controller.model.comments}}
        @onCreateSubscription={{fn @controller.createSubscription}}
        @onDeleteSubscription={{fn @controller.deleteSubscription}}
        @onSubmit={{fn @controller.createComment}}
        @onUpdateComment={{fn @controller.updateComment}}
        @onDeleteComment={{fn @controller.deleteComment}}
        @onSelectPage={{fn @controller.selectPage}}
      />
    {{/if}}
  </template>
);
