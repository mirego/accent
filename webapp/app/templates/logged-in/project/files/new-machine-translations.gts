import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import AccModal from 'accent-webapp/components/acc-modal/index';
import {fn} from '@ember/helper';
import MachineTranslationsTranslateUploadForm from 'accent-webapp/components/machine-translations-translate-upload-form/index';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <AccModal @onClose={{fn @controller.closeModal}}>
      <MachineTranslationsTranslateUploadForm
        @revisions={{@controller.model.project.revisions}}
        @onFileChange={{fn @controller.translate}}
        @onFileReset={{fn @controller.resetContent}}
        @translatedFileContent={{@controller.translatedFileContent}}
      />
    </AccModal>
  </template>
);
