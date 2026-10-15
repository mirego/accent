import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import TranslationSplashTitleSkeleton from 'accent-webapp/components/skeleton-ui/translation-splash-title/index';
import TranslationSplashTitle from 'accent-webapp/components/translation-splash-title/index';
import TranslationNavigation from 'accent-webapp/components/translation-navigation/index';
import ProgressLine from 'accent-webapp/components/skeleton-ui/progress-line/index';
import {pageTitle} from 'ember-page-title';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    {{pageTitle @controller.model.translation.key}}

    {{#if @controller.showSkeleton}}
      <TranslationSplashTitleSkeleton />
    {{else}}
      <TranslationSplashTitle
        @project={{@controller.model.project}}
        @translation={{@controller.model.translation}}
      />
    {{/if}}

    <TranslationNavigation
      @project={{@controller.model.project}}
      @permissions={{@controller.permissions}}
      @translation={{@controller.model.translation}}
    />

    {{#if @controller.model.loading}}
      <ProgressLine />
    {{/if}}

    {{outlet}}
  </template>
);
