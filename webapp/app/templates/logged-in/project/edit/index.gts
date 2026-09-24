import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import ProjectSettingsSkeleton from 'accent-webapp/components/skeleton-ui/project-settings/index';
import Form from 'accent-webapp/components/project-settings/form/index';
import {fn, get} from '@ember/helper';
import LinksList from 'accent-webapp/components/project-settings/links-list/index';
import LockForm from 'accent-webapp/components/project-settings/lock-form/index';
import DeleteForm from 'accent-webapp/components/project-settings/delete-form/index';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    {{#if @controller.showLoading}}
      <ProjectSettingsSkeleton />
    {{else}}
      <Form
        @project={{@controller.project}}
        @permissions={{@controller.permissions}}
        @onUpdateProject={{fn @controller.updateProject}}
      />

      <LinksList
        @project={{@controller.project}}
        @permissions={{@controller.permissions}}
      />

      <LockForm
        @project={{@controller.project}}
        @permissions={{@controller.permissions}}
        @onUpdateProject={{fn @controller.updateProject}}
      />

      {{#if (get @controller.permissions 'deleteProject')}}
        <DeleteForm
          @project={{@controller.project}}
          @onSubmit={{fn @controller.deleteProject}}
        />
      {{/if}}
    {{/if}}
  </template>
);
