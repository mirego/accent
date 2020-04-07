import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import Component from '@glimmer/component';
import Exporter from 'accent-webapp/services/exporter';
import {tracked} from '@glimmer/tracking';

interface Args {
  project: any;
  document: any;
  version: any;
  documentFormat: any;
  onFileLoaded: (data: any) => void;
}

export default class JIPTExport extends Component<Args> {
  @service('exporter')
  exporter: Exporter;

  @tracked
  content = '';

  @action
  async onUpdate() {
    const data = await this.exporter.jipt({
      project: this.args.project,
      document: this.args.document,
      version: this.args.version,
      documentFormat: this.args.documentFormat,
    });

    this.content = data;
    this.args.onFileLoaded(data);
  }
}
