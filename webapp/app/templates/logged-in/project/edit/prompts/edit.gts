import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import AccModal from 'accent-webapp/components/acc-modal/index';
import {fn} from '@ember/helper';
import PromptUpdateForm from 'accent-webapp/components/prompt-update-form/index';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <AccModal @small={{true}} @onClose={{fn @controller.closeModal}}>
      <PromptUpdateForm
        @prompt={{@controller.prompt}}
        @error={{@controller.error}}
        @project={{@controller.project}}
        @onUpdate={{fn @controller.update}}
      />
    </AccModal>
  </template>
);
