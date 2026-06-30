import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import BackLink from 'accent-webapp/components/project-settings/back-link/index';
import LoadingContent from 'accent-webapp/components/loading-content/index';
import t from 'ember-intl/helpers/t';
import Prompts from 'accent-webapp/components/project-settings/prompts/index';
import {fn} from '@ember/helper';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <BackLink @project={{@controller.project}} />

    {{#if @controller.showLoading}}
      <LoadingContent
        @label={{t 'pods.project.edit.prompts.loading_content'}}
      />
    {{else}}
      <Prompts
        @project={{@controller.project}}
        @prompts={{@controller.prompts}}
        @onSaveConfig={{fn @controller.savePromptConfig}}
        @onDeleteConfig={{fn @controller.deletePromptConfig}}
        @onDeletePrompt={{fn @controller.deletePrompt}}
      />

      {{outlet}}
    {{/if}}
  </template>
);
