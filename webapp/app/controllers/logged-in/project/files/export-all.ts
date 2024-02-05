import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import {readOnly, empty} from '@ember/object/computed';
import Controller from '@ember/controller';
import FileSaver from 'accent-webapp/services/file-saver';
import GlobalState from 'accent-webapp/services/global-state';
import {tracked} from '@glimmer/tracking';
import RouterService from '@ember/routing/router-service';
import FromRoute from 'accent-webapp/services/from-route';

export default class ExportAllController extends Controller {
  @tracked
  model: any;

  @service('file-saver')
  fileSaver: FileSaver;

  @service('global-state')
  globalState: GlobalState;

  @service('router')
  router: RouterService;

  @service('from-route')
  fromRoute: FromRoute;

  queryParams = [
    'revisionFilter',
    'documentFormatFilter',
    'orderByFilter',
    'versionFilter',
    'isTextEmpty',
    'isAddedLastSync',
    'isConflictedFilter',
  ];

  @tracked
  exportLoading = true;

  @tracked
  fileRender: any = null;

  @tracked
  revisionFilter = null;

  @tracked
  documentFormatFilter = 'JSON';

  @tracked
  orderByFilter = '';

  @tracked
  versionFilter = '';

  @tracked
  isTextEmpty: 'true' | null = null;

  @tracked
  isAddedLastSync: 'true' | null = null;

  @tracked
  isConflicted: 'true' | null = null;

  @readOnly('model.projectModel.project')
  project: any;

  @readOnly('project.revisions')
  revisions: any;

  @readOnly('model.fileModel.versions.entries')
  versions: any;

  @readOnly('model.fileModel.documents.entries')
  documents: any;

  @readOnly('model.fileModel.loading')
  showLoading: boolean;

  @empty('fileRender')
  exportButtonDisabled: boolean;

  get revision() {
    if (!this.revisions) return;

    return this.revisions.find(
      ({id}: {id: string}) => id === this.revisionFilter
    );
  }

  get document() {
    if (!this.documents) return;

    return this.documents[0];
  }

  get fileExtension() {
    if (!this.globalState.documentFormats) return '';

    const format =
      this.documentFormatFilter || this.globalState.documentFormats[0].slug;

    const documentFormatItem = this.globalState.documentFormats.find(
      ({slug}) => slug === format
    );

    if (!documentFormatItem) return '';

    return documentFormatItem.extension;
  }

  @action
  closeModal() {
    this.fromRoute.transitionTo(
      this.model.from,
      'logged-in.project.files',
      'logged-in.project.files',
      this.project.id
    );
  }

  @action
  onFileLoaded(content: any) {
    this.fileRender = content;
    this.exportLoading = false;
  }

  @action
  changeAdvancedFilterBoolean(
    key: 'isTextEmpty' | 'isAddedLastSync' | 'isConflicted',
    event: InputEvent
  ) {
    this[key] = (event.target as HTMLInputElement).checked ? 'true' : null;
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
