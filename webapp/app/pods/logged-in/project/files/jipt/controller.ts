import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import {readOnly, empty} from '@ember/object/computed';
import Controller from '@ember/controller';
import FileSaver from 'accent-webapp/services/file-saver';
import GlobalState from 'accent-webapp/services/global-state';
import {tracked} from '@glimmer/tracking';
import RouterService from '@ember/routing/router-service';

export default class JIPTController extends Controller {
  @service('file-saver')
  fileSaver: FileSaver;

  @service('global-state')
  globalState: GlobalState;

  @service('router')
  router: RouterService;

  queryParams = ['documentFormatFilter'];

  @tracked
  documentFormatFilter = null;

  @tracked
  exportLoading = true;

  @tracked
  fileRender: any = null;

  @readOnly('model.projectModel.project')
  project: any;

  @readOnly('project.revisions')
  revisions: any;

  @readOnly('model.fileModel.documents.entries')
  documents: any;

  @readOnly('model.fileModel.loading')
  showLoading: boolean;

  @empty('fileRender')
  exportButtonDisabled: boolean;

  get document() {
    if (!this.documents) return;

    return this.documents.find(({id}: {id: string}) => {
      return id === this.model.fileId;
    });
  }

  get documentFormatItem() {
    if (!this.globalState.documentFormats) return {};

    return this.globalState.documentFormats.find(({slug}) => {
      return slug === this.document.format;
    });
  }

  get fileExtension() {
    if (!this.globalState.documentFormats) return '';

    const format = this.documentFormatFilter || this.document.format;

    const documentFormatItem = this.globalState.documentFormats.find(
      ({slug}) => slug === format
    );

    if (!documentFormatItem) return '';

    return documentFormatItem.extension;
  }

  @action
  closeModal() {
    this.router.transitionTo('logged-in.project.files', this.project.id);
  }

  @action
  onFileLoaded(content: any) {
    this.fileRender = content;
    this.exportLoading = false;
  }

  @action
  exportFile() {
    const blob = new Blob([this.fileRender], {
      type: 'charset=utf-8',
    });

    const filename = `${this.document.path}.${this.fileExtension}`;

    this.fileSaver.saveAs(blob, filename);
  }
}
