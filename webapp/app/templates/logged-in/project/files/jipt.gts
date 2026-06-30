import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import AccModal from 'accent-webapp/components/acc-modal/index';
import {fn, array} from '@ember/helper';
import ProjectFileOperation from 'accent-webapp/components/project-file-operation/index';
import {on} from '@ember/modifier';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import t from 'ember-intl/helpers/t';
import RevisionExportOptions from 'accent-webapp/components/revision-export-options/index';
import {LinkTo} from '@ember/routing';
import AsyncButton from 'accent-webapp/components/async-button/index';
import ProgressLine from 'accent-webapp/components/skeleton-ui/progress-line/index';
import JiptExport from 'accent-webapp/components/jipt-export/index';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <AccModal @onClose={{fn @controller.closeModal}}>
      <ProjectFileOperation>
        <button class='closeButton' {{on 'click' (fn @controller.closeModal)}}>
          <div class='closeButton-content'>
            {{inlineSvg '/assets/x.svg' class='closeButton-icon'}}
          </div>
        </button>

        <div class='title'>
          <div class='sectionType'>
            {{inlineSvg '/assets/edit-in-place.svg' class='sectionType-icon'}}
            {{t 'components.project_file_operations.export_jipt'}}
          </div>

          <div class='title-document'>
            {{@controller.document.path}}

            <span
              class='title-documentExtension'
            >.{{@controller.documentFormatItem.extension}}</span>
          </div>
        </div>

        <RevisionExportOptions
          @format={{@controller.documentFormatFilter}}
          @onChangeFormat={{fn (mut @controller.documentFormatFilter)}}
        />

        <LinkTo
          @route='logged-in.project.files.export'
          @models={{array @controller.project.id @controller.document.id}}
          class='button button--filled button--white button--small toggleJiptExport'
        >
          {{inlineSvg '/assets/export.svg' class='button-icon'}}
          {{t 'components.project_file_operations.export'}}
        </LinkTo>

        <AsyncButton
          @onClick={{fn @controller.exportFile}}
          @disabled={{@controller.exportButtonDisabled}}
          class='button button--filled renderExport'
        >
          {{t 'components.project_file_operations.export'}}
        </AsyncButton>

        {{#if @controller.exportLoading}}
          <ProgressLine />
        {{/if}}

        <JiptExport
          class='render'
          @onFileLoaded={{fn @controller.onFileLoaded}}
          @project={{@controller.project}}
          @document={{@controller.document}}
          @documentFormat={{@controller.documentFormatFilter}}
        />
      </ProjectFileOperation>
    </AccModal>
  </template>
);
