import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import AccModal from 'accent-webapp/components/acc-modal/index';
import {fn} from '@ember/helper';
import ProjectCreateForm from 'accent-webapp/components/project-create-form/index';
import {pageTitle} from 'ember-page-title';
import t from 'ember-intl/helpers/t';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    {{pageTitle (t 'general.page_titles.new_project')}}

    <AccModal @small={{true}} @onClose={{fn @controller.closeModal}}>
      <ProjectCreateForm
        @error={{@controller.error}}
        @languages={{@controller.model.languages}}
        @onCreate={{fn @controller.create}}
      />
    </AccModal>
  </template>
);
