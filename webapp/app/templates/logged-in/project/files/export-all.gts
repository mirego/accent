import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import AccModal from 'accent-webapp/components/acc-modal/index';
import {fn} from '@ember/helper';
import ProjectFileOperation from 'accent-webapp/components/project-file-operation/index';
import {on} from '@ember/modifier';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import t from 'ember-intl/helpers/t';
import RevisionExportOptions from 'accent-webapp/components/revision-export-options/index';
import AsyncButton from 'accent-webapp/components/async-button/index';
import ProgressLine from 'accent-webapp/components/skeleton-ui/progress-line/index';
import FileExportAll from 'accent-webapp/components/file-export-all/index';
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
            {{inlineSvg '/assets/export.svg' class='sectionType-icon'}}
            {{t 'components.project_file_operations.export_all'}}
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

        <FileExportAll
          class='render'
          @onFileLoaded={{fn @controller.onFileLoaded}}
          @project={{@controller.project}}
          @revisions={{@controller.revisions}}
          @revision={{@controller.revision}}
          @version={{@controller.versionFilter}}
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
