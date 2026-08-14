import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import AccModal from 'accent-webapp/components/acc-modal/index';
import {fn} from '@ember/helper';
import ProjectFileOperation from 'accent-webapp/components/project-file-operation/index';
import {on} from '@ember/modifier';
import EmptySvg from 'accent-webapp/svgs/assets/empty.svg';
import XSvg from 'accent-webapp/svgs/assets/x.svg';
import RevisionExportOptions from 'accent-webapp/components/revision-export-options/index';
import AsyncButton from 'accent-webapp/components/async-button/index';
import t from 'ember-intl/helpers/t';
import ProgressLine from 'accent-webapp/components/skeleton-ui/progress-line/index';
import EmptyContent from 'accent-webapp/components/empty-content/index';
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
            <div class='versionTitle'>
              <strong class='versionTitle-name'>
                {{@controller.version.name}}
              </strong>
              <span class='versionTitle-tag'>
                {{@controller.version.tag}}
              </span>
            </div>
          </div>
        </div>

        {{#if @controller.document}}
          <RevisionExportOptions
            @format={{@controller.documentFormatFilter}}
            @documents={{@controller.documents}}
            @document={{@controller.documentFilter}}
            @orderBy={{@controller.orderByFilter}}
            @revision={{@controller.revisionFilter}}
            @revisions={{@controller.revisions}}
            @onChangeDocument={{fn (mut @controller.documentFilter)}}
            @onChangeRevision={{fn (mut @controller.revisionFilter)}}
            @onChangeFormat={{fn (mut @controller.documentFormatFilter)}}
            @onChangeOrderBy={{fn (mut @controller.orderByFilter)}}
          />
        {{/if}}

        <AsyncButton
          @onClick={{fn @controller.exportFile}}
          @disabled={{@controller.exportButtonDisabled}}
          class='button button--filled renderExport'
        >
          {{t 'components.project_file_operations.export'}}
        </AsyncButton>

        {{#if @controller.document}}
          {{#if @controller.exportLoading}}
            <ProgressLine />
          {{/if}}
        {{else}}
          <EmptyContent
            @text={{t 'pods.project.versions.export.empty_documents'}}
            @icon={{EmptySvg}}
            @center={{true}}
            @background='transparent'
          />
        {{/if}}

        <FileExport
          class='render'
          @onFileLoaded={{fn @controller.onFileLoaded}}
          @project={{@controller.project}}
          @revisions={{@controller.revisions}}
          @revision={{@controller.revision}}
          @document={{@controller.document}}
          @version={{@controller.version.tag}}
          @documentFormat={{@controller.documentFormatFilter}}
          @orderBy={{@controller.orderByFilter}}
        />
      </ProjectFileOperation>
    </AccModal>
  </template>
);
