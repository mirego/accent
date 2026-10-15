import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import TranslationSettingsForm from 'accent-webapp/components/translation-settings-form/index';
import {fn} from '@ember/helper';
import {pageTitle} from 'ember-page-title';
import t from 'ember-intl/helpers/t';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    {{pageTitle (t 'general.page_titles.settings')}}

    {{#if @controller.model.translation}}
      <TranslationSettingsForm
        @translation={{@controller.model.translation}}
        @permissions={{@controller.permissions}}
        @onUpdateSettings={{fn @controller.updateSettings}}
      />
    {{/if}}
  </template>
);
