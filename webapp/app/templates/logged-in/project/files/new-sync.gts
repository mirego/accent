import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import AccModal from 'accent-webapp/components/acc-modal/index';
import {fn} from '@ember/helper';
import ProjectFileOperation from 'accent-webapp/components/project-file-operation/index';
import {on} from '@ember/modifier';
import SyncSvg from 'accent-webapp/svgs/assets/sync.svg';
import XSvg from 'accent-webapp/svgs/assets/x.svg';
import t from 'ember-intl/helpers/t';
import CommitFile from 'accent-webapp/components/commit-file/index';
import OperationsPeek from 'accent-webapp/components/operations-peek/index';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <AccModal @large={{true}} @onClose={{fn @controller.closeModal}}>
      <ProjectFileOperation>
        <button class='closeButton' {{on 'click' (fn @controller.closeModal)}}>
          <div class='closeButton-content'>
            <XSvg class='closeButton-icon' />
          </div>
        </button>

        <div class='title'>
          <div class='sectionType'>
            <SyncSvg class='sectionType-icon' />
            {{t 'components.project_file_operations.sync'}}
          </div>
        </div>

        <div class='sections'>
          <div class='sections-file'>
            <CommitFile
              @permissions={{@controller.permissions}}
              @revisions={{@controller.revisions}}
              @documents={{@controller.documents}}
              @versions={{@controller.versions}}
              @canCommit={{true}}
              @commitAction='sync'
              @peekAction='peekSync'
              @commitButtonText={{t 'components.commit_file.sync_button'}}
              @onFileCancel={{fn @controller.cancelFile}}
              @onPeek={{fn @controller.peek}}
              @onCommit={{fn @controller.sync}}
            />
          </div>

          {{#if @controller.revisionOperations.length}}
            <div class='sections-preview'>
              <OperationsPeek
                @revisionOperations={{@controller.revisionOperations}}
              />
            </div>
          {{/if}}
        </div>
      </ProjectFileOperation>
    </AccModal>
  </template>
);
