import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import AccModal from 'accent-webapp/components/acc-modal/index';
import {fn} from '@ember/helper';
import PromptCreateForm from 'accent-webapp/components/prompt-create-form/index';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <AccModal @small={{true}} @onClose={{fn @controller.closeModal}}>
      <PromptCreateForm
        @error={{@controller.error}}
        @project={{@controller.project}}
        @onCreate={{fn @controller.create}}
      />
    </AccModal>
  </template>
);
