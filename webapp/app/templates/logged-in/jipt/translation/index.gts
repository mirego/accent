import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import TranslationEdit from 'accent-webapp/components/translation-edit/index';
import {fn} from '@ember/helper';
import RemovedTranslationEdit from 'accent-webapp/components/removed-translation-edit/index';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    {{#unless @controller.translation.removed}}
      <TranslationEdit
        @translation={{@controller.model.translation}}
        @project={{@controller.model.project}}
        @prompts={{@controller.model.prompts}}
        @revisions={{@controller.model.revisions}}
        @permissions={{@controller.permissions}}
        @onChangeText={{fn @controller.changeText}}
        @onUpdateText={{fn @controller.updateText}}
        @onCorrectConflict={{fn @controller.correctConflict}}
        @onUncorrectConflict={{fn @controller.uncorrectConflict}}
      />
    {{else}}
      <RemovedTranslationEdit @translation={{@controller.model.translation}} />
    {{/unless}}
  </template>
);
