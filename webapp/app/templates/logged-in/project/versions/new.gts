import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import AccModal from 'accent-webapp/components/acc-modal/index';
import {fn} from '@ember/helper';
import VersionCreateForm from 'accent-webapp/components/version-create-form/index';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <AccModal @small={{true}} @onClose={{fn @controller.closeModal}}>
      <VersionCreateForm
        @error={{@controller.error}}
        @project={{@controller.model.project}}
        @onCreate={{fn @controller.create}}
      />
    </AccModal>
  </template>
);
