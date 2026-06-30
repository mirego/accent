import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import TranslationIndex from 'accent-webapp/components/translation-index/index';
import TranslationEdit from 'accent-webapp/components/translation-edit/index';
import {fn, get} from '@ember/helper';
import RelatedTranslationsList from 'accent-webapp/components/related-translations-list/index';
import RemovedTranslationEdit from 'accent-webapp/components/removed-translation-edit/index';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    {{#unless @controller.translation.removed}}
      <TranslationIndex>
        <TranslationEdit
          @translation={{@controller.model.translation}}
          @prompts={{@controller.model.prompts}}
          @project={{@controller.model.project}}
          @revisions={{@controller.model.revisions}}
          @permissions={{@controller.permissions}}
          @onUpdateText={{fn @controller.updateText}}
          @onCorrectConflict={{fn @controller.correctConflict}}
          @onUncorrectConflict={{fn @controller.uncorrectConflict}}
        />

        {{#if @controller.model.relatedTranslations}}
          {{#if (get @controller.permissions 'indexRelatedTranslations')}}
            <RelatedTranslationsList
              @project={{@controller.model.project}}
              @permissions={{@controller.permissions}}
              @prompts={{@controller.model.prompts}}
              @translations={{@controller.model.relatedTranslations}}
              @onUpdateText={{fn @controller.updateTranslation}}
            />
          {{/if}}
        {{/if}}
      </TranslationIndex>
    {{else}}
      <RemovedTranslationEdit @translation={{@controller.model.translation}} />
    {{/unless}}
  </template>
);
