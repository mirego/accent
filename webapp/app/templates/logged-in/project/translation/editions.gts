import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import ProgressLine from 'accent-webapp/components/skeleton-ui/progress-line/index';
import TranslationsList from 'accent-webapp/components/skeleton-ui/translations-list/index';
import LoadingContent from 'accent-webapp/components/loading-content/index';
import t from 'ember-intl/helpers/t';
import TranslationEditionsList from 'accent-webapp/components/translation-editions-list/index';
import {fn} from '@ember/helper';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    {{#if @controller.model.loading}}
      <ProgressLine />
    {{/if}}

    {{#if @controller.showSkeleton}}
      <TranslationsList />
    {{else if @controller.showLoading}}
      <LoadingContent
        @label={{t 'pods.project.translations.loading_content'}}
      />
    {{else}}
      <TranslationEditionsList
        @project={{@controller.model.project}}
        @prompts={{@controller.model.prompts}}
        @revisions={{@controller.revisions}}
        @permissions={{@controller.permissions}}
        @translations={{@controller.model.translations}}
        @onUpdateText={{fn @controller.updateText}}
      />
    {{/if}}
  </template>
);
