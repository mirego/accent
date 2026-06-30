import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import BackLink from 'accent-webapp/components/project-settings/back-link/index';
import LoadingContent from 'accent-webapp/components/loading-content/index';
import t from 'ember-intl/helpers/t';
import MachineTranslations from 'accent-webapp/components/project-settings/machine-translations/index';
import {fn} from '@ember/helper';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <BackLink @project={{@controller.project}} />

    {{#if @controller.showLoading}}
      <LoadingContent
        @label={{t 'pods.project.edit.machine_translations.loading_content'}}
      />
    {{else}}
      <MachineTranslations
        @project={{@controller.project}}
        @onSave={{fn @controller.saveMachineTranslationsConfig}}
        @onDelete={{fn @controller.deleteMachineTranslationsConfig}}
      />
    {{/if}}
  </template>
);
