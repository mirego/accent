import {inject as service} from '@ember/service';
import Component from '@ember/component';

// Attributes:
// project: Object <project>
// document: Object <document>
// revision: Object <revision>
// documentFormat: String
// orderBy: String
export default Component.extend({
  exporter: service(),

  content: '',

  didReceiveAttrs() {
    this._super(...arguments);

    if (!this.revision && !this.revisions) return;
    if (!this.document) return;

    const revision = this.revision || this.revisions[0];

    this.exporter
      .export({
        revision,
        ...this.getProperties('project', 'document', 'version', 'documentFormat', 'orderBy')
      })
      .then(data => this.set('content', data))
      .then(data => this.onFileLoaded(data));
  }
});
