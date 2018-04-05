import {computed} from '@ember/object';
import {not} from '@ember/object/computed';
import {inject as service} from '@ember/service';
import Component from '@ember/component';

// Attributes:
// project: Object <project>
// permissions: Ember Object containing <permission>
// document: Object <revision>
// onDelete: Function
export default Component.extend({
  globalState: service('global-state'),

  tagName: 'li',

  classNames: ['item'],

  isDeleting: false,
  canDeleteFile: not('project.lockedFileOperations'),

  documentFormatItem: computed('document.format', function() {
    if (!this.globalState.documentFormats) return {};

    return this.globalState.documentFormats.find(({slug}) => slug === this.document.format);
  }),

  actions: {
    deleteFile() {
      this.set('isDeleting', true);

      this.onDelete(this.document).then(() => this.set('isDeleting', false));
    }
  }
});
