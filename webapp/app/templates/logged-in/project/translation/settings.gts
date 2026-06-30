import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import TranslationSettingsForm from 'accent-webapp/components/translation-settings-form/index';
import {fn} from '@ember/helper';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    {{#if @controller.model.translation}}
      <TranslationSettingsForm
        @translation={{@controller.model.translation}}
        @permissions={{@controller.permissions}}
        @onUpdateSettings={{fn @controller.updateSettings}}
      />
    {{/if}}
  </template>
);
