import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import {readOnly, empty} from '@ember/object/computed';
import Controller from '@ember/controller';
import FileSaver from 'accent-webapp/services/file-saver';
import GlobalState from 'accent-webapp/services/global-state';
import {tracked} from '@glimmer/tracking';
import RouterService from '@ember/routing/router-service';

export default class ExportController extends Controller {
  @service('file-saver')
  fileSaver: FileSaver;

  @service('global-state')
  globalState: GlobalState;

  @service('router')
  router: RouterService;

  queryParams = [
    'revisionFilter',
    'documentFilter',
    'documentFormatFilter',
    'orderByFilter',
  ];

  @tracked
  exportLoading = true;

  @tracked
  fileRender: any = null;

  @tracked
  documentFormatFilter = null;

  @tracked
  documentFilter = null;

  @tracked
  orderByFilter = null;

  @tracked
  revisionFilter = null;

  @readOnly('model.projectModel.project')
  project: any;

  @readOnly('project.revisions')
  revisions: any;

  @readOnly('model.versionModel.documents.entries')
  documents: any;

  @readOnly('model.versionModel.versions.entries')
  versions: any;

  @readOnly('model.versionModel.loading')
  showLoading: boolean;

  @empty('fileRender')
  exportButtonDisabled: boolean;

  get revision() {
    if (!this.revisions) return;

    return this.revisions.find(({id}: {id: string}) => {
      return id === this.revisionFilter;
    });
  }

  get version() {
    if (!this.versions) return;

    return this.versions.find(({id}: {id: string}) => {
      return id === this.model.versionId;
    });
  }

  get document() {
    if (!this.documents) return;

    return (
      this.documents.find(({id}: {id: string}) => {
        return id === this.documentFilter;
      }) || this.documents[0]
    );
  }

  get fileExtension() {
    if (!this.globalState.documentFormats) return '';

    const format = this.documentFormatFilter || this.document.format;

    const documentFormatItem = this.globalState.documentFormats.find(
      ({slug}) => {
        return slug === format;
      }
    );

    if (!documentFormatItem) return '';

    return documentFormatItem.extension;
  }

  @action
  closeModal() {
    this.router.transitionTo('logged-in.project.versions', this.project.id);
  }

  @action
  onFileLoaded(content: any) {
    this.fileRender = content;
    this.exportLoading = false;
  }

  exportFile() {
    const blob = new Blob([this.fileRender], {
      type: 'charset=utf-8',
    });

    const filename = `${this.document.path}.${this.fileExtension}`;

    this.fileSaver.saveAs(blob, filename);
  }
}
