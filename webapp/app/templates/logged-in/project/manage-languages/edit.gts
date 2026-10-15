import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import AccModal from 'accent-webapp/components/acc-modal/index';
import {fn} from '@ember/helper';
import RevisionUpdateForm from 'accent-webapp/components/revision-update-form/index';
import {pageTitle} from 'ember-page-title';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    {{pageTitle @controller.revisionName}}

    {{#if @controller.revision}}
      <AccModal @small={{true}} @onClose={{fn @controller.closeModal}}>
        <RevisionUpdateForm
          @project={{@controller.project}}
          @revision={{@controller.revision}}
          @onUpdate={{fn @controller.update}}
        />
      </AccModal>
    {{/if}}
  </template>
);
