import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import JiptTranslation from 'accent-webapp/components/jipt-translation/index';
import TranslationSplashTitleSkeleton from 'accent-webapp/components/skeleton-ui/translation-splash-title/index';
import TranslationSplashTitle from 'accent-webapp/components/translation-splash-title/index';
import JiptBackToTranslations from 'accent-webapp/components/jipt-back-to-translations/index';
import ProgressLine from 'accent-webapp/components/skeleton-ui/progress-line/index';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <JiptTranslation>
      {{#if @controller.showSkeleton}}
        <TranslationSplashTitleSkeleton />
      {{else}}
        <JiptBackToTranslations />
        <TranslationSplashTitle
          @project={{@controller.model.project}}
          @translation={{@controller.model.translation}}
          @withRevisionLink={{false}}
        />
      {{/if}}

      {{#if @controller.model.loading}}
        <ProgressLine />
      {{/if}}

      {{outlet}}
    </JiptTranslation>
  </template>
);
