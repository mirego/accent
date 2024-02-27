import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import Component from '@glimmer/component';
import Exporter from 'accent-webapp/services/exporter';
import {tracked} from '@glimmer/tracking';

interface Args {
  class: string;
  onFileLoaded: (data: any) => void;
  project: any;
  revisions: any;
  revision: any;
  document: string;
  documentFormat: string;
  orderBy: string;
  version?: string;
  isTextEmptyFilter?: boolean;
  isAddedLastSyncFilter?: boolean;
  isConflictedFilter?: boolean;
}

export default class FileExport extends Component<Args> {
  @service('exporter')
  exporter: Exporter;

  @tracked
  content = '';

  @action
  async onUpdate() {
    if (!this.args.revision && !this.args.revisions) return;

    const revision = this.args.revision || this.args.revisions[0];

    const data = await this.exporter.exportAll({
      revision,
      project: this.args.project,
      version: this.args.version,
      documentFormat: this.args.documentFormat,
      orderBy: this.args.orderBy,
      filters: {
        isTextEmptyFilter: this.args.isTextEmptyFilter,
        isAddedLastSyncFilter: this.args.isAddedLastSyncFilter,
        isConflictedFilter: this.args.isConflictedFilter
      }
    });

    this.content = data;
    this.args.onFileLoaded(data);
  }
}
