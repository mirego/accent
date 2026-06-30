import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import AccModal from 'accent-webapp/components/acc-modal/index';
import {fn} from '@ember/helper';
import ProjectFileOperation from 'accent-webapp/components/project-file-operation/index';
import {on} from '@ember/modifier';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import t from 'ember-intl/helpers/t';
import MachineTranslationsDocumentTranslate from 'accent-webapp/components/machine-translations-document-translate/index';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <AccModal @onClose={{fn @controller.closeModal}} @large={{true}}>
      <ProjectFileOperation>
        <button class='closeButton' {{on 'click' (fn @controller.closeModal)}}>
          <div class='closeButton-content'>
            {{inlineSvg '/assets/x.svg' class='closeButton-icon'}}
          </div>
        </button>

        <div class='title'>
          <div class='sectionType'>
            {{inlineSvg '/assets/language.svg' class='sectionType-icon'}}
            {{t 'components.project_file_operations.translate'}}
          </div>

          <div class='title-document'>
            {{@controller.document.path}}
            <span class='title-documentExtension'>
              .
              {{@controller.documentFormatItem.extension}}
            </span>
          </div>
        </div>

        <MachineTranslationsDocumentTranslate
          @project={{@controller.model.projectModel.project}}
          @document={{@controller.document}}
          @revisions={{@controller.model.projectModel.project.revisions}}
          @onTranslate={{fn @controller.translate}}
          @translatedFileContent={{@controller.translatedFileContent}}
        />
      </ProjectFileOperation>
    </AccModal>
  </template>
);
