import {service} from '@ember/service';
import {action} from '@ember/object';
import Component from '@glimmer/component';
import Exporter from 'accent-webapp/services/exporter';
import {tracked} from '@glimmer/tracking';
import HighlightRender from 'accent-webapp/components/highlight-render/index';
import didInsert from '@ember/render-modifiers/modifiers/did-insert';
import {fn} from '@ember/helper';
import didUpdate from '@ember/render-modifiers/modifiers/did-update';

interface Args {
  project: any;
  document: any;
  version: any;
  documentFormat: any;
  onFileLoaded: (data: any) => void;
}

export default class JIPTExport extends Component<Args> {
  <template>
    <HighlightRender
      ...attributes
      {{didInsert (fn this.onUpdate)}}
      {{didUpdate
        (fn this.onUpdate)
        @project
        @document
        @version
        @documentFormat
      }}
      @content={{this.content}}
    />
  </template>
  @service('exporter')
  declare exporter: Exporter;

  @tracked
  content = '';

  @action
  async onUpdate() {
    const data = await this.exporter.jipt({
      project: this.args.project,
      document: this.args.document,
      version: this.args.version,
      documentFormat: this.args.documentFormat
    });

    this.content = data;
    this.args.onFileLoaded(data);
  }
}
