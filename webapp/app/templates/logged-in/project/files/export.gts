import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import AccModal from 'accent-webapp/components/acc-modal/index';
import {fn, array} from '@ember/helper';
import ProjectFileOperation from 'accent-webapp/components/project-file-operation/index';
import {on} from '@ember/modifier';
import EditInPlaceSvg from 'accent-webapp/svgs/assets/edit-in-place.svg';
import ExportSvg from 'accent-webapp/svgs/assets/export.svg';
import XSvg from 'accent-webapp/svgs/assets/x.svg';
import t from 'ember-intl/helpers/t';
import RevisionExportOptions from 'accent-webapp/components/revision-export-options/index';
import {LinkTo} from '@ember/routing';
import AsyncButton from 'accent-webapp/components/async-button/index';
import ProgressLine from 'accent-webapp/components/skeleton-ui/progress-line/index';
import FileExport from 'accent-webapp/components/file-export/index';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <AccModal @onClose={{fn @controller.closeModal}}>
      <ProjectFileOperation>
        <button class='closeButton' {{on 'click' (fn @controller.closeModal)}}>
          <div class='closeButton-content'>
            <XSvg class='closeButton-icon' />
          </div>
        </button>

        <div class='title'>
          <div class='sectionType'>
            <ExportSvg class='sectionType-icon' />
            {{t 'components.project_file_operations.export'}}
          </div>

          <div class='title-document'>
            {{@controller.document.path}}
            <span class='title-documentExtension'>
              .
              {{@controller.documentFormatItem.extension}}
            </span>
          </div>
        </div>
        <RevisionExportOptions
          @format={{@controller.documentFormatFilter}}
          @version={{@controller.versionFilter}}
          @orderBy={{@controller.orderByFilter}}
          @revision={{@controller.revisionFilter}}
          @revisions={{@controller.revisions}}
          @versions={{@controller.versions}}
          @onChangeVersion={{fn (mut @controller.versionFilter)}}
          @onChangeRevision={{fn (mut @controller.revisionFilter)}}
          @onChangeFormat={{fn (mut @controller.documentFormatFilter)}}
          @onChangeOrderBy={{fn (mut @controller.orderByFilter)}}
          @isTextEmptyFilter={{@controller.isTextEmpty}}
          @isAddedLastSyncFilter={{@controller.isAddedLastSync}}
          @isConflictedFilter={{@controller.isConflicted}}
          @onChangeAdvancedFilterBoolean={{fn
            @controller.changeAdvancedFilterBoolean
          }}
        />
        <LinkTo
          @route='logged-in.project.files.jipt'
          @models={{array @controller.project.id @controller.document.id}}
          class='button button--filled button--white button--small toggleJiptExport'
        >
          <EditInPlaceSvg class='button-icon' />
          {{t 'components.project_file_operations.export_jipt'}}
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

        <FileExport
          class='render'
          @onFileLoaded={{fn @controller.onFileLoaded}}
          @project={{@controller.project}}
          @revisions={{@controller.revisions}}
          @revision={{@controller.revision}}
          @version={{@controller.versionFilter}}
          @document={{@controller.document}}
          @documentFormat={{@controller.documentFormatFilter}}
          @isTextEmptyFilter={{@controller.isTextEmpty}}
          @isAddedLastSyncFilter={{@controller.isAddedLastSync}}
          @isConflictedFilter={{@controller.isConflicted}}
          @orderBy={{@controller.orderByFilter}}
        />
      </ProjectFileOperation>
    </AccModal>
  </template>
);
