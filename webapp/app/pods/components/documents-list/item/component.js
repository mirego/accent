import {computed} from '@ember/object';
import {not, lt, gte, reads} from '@ember/object/computed';
import {inject as service} from '@ember/service';
import {scheduleOnce} from '@ember/runloop';
import Component from '@ember/component';
import percentage from 'accent-webapp/component-helpers/percentage';

const LOW_PERCENTAGE = 50;
const HIGH_PERCENTAGE = 90;

// Attributes:
// project: Object <project>
// permissions: Ember Object containing <permission>
// document: Object <revision>
// onDelete: Function
// onRename: Function
export default Component.extend({
  lowPercentage: lt('correctedKeysPercentage', LOW_PERCENTAGE), // Lower than low percentage
  mediumPercentage: gte('correctedKeysPercentage', LOW_PERCENTAGE), // higher or equal than low percentage
  highPercentage: gte('correctedKeysPercentage', HIGH_PERCENTAGE), // higher or equal than high percentage

  classNameBindings: ['lowPercentage', 'mediumPercentage', 'highPercentage'],

  globalState: service('global-state'),

  tagName: 'li',

  isEditing: false,
  isDeleting: false,
  isUpdating: false,
  renamedDocumentPath: reads('document.path'),
  canDeleteFile: not('project.lockedFileOperations'),

  documentFormatItem: computed(
    'document.format',
    'globalState.documentFormats',
    function() {
      if (!this.globalState.documentFormats) return {};

      return this.globalState.documentFormats.find(
        ({slug}) => slug === this.document.format
      );
    }
  ),

  correctedKeysPercentage: computed(
    'document.{conflictsCount,translationsCount}',
    function() {
      return percentage(
        this.document.translationsCount - this.document.conflictsCount,
        this.document.translationsCount
      );
    }
  ),

  reviewsCount: computed(
    'document.{conflictsCount,translationsCount}',
    function() {
      const {conflictsCount, translationsCount} = this.document;

      return translationsCount - conflictsCount;
    }
  ),

  actions: {
    deleteFile() {
      this.set('isDeleting', true);

      this.onDelete(this.document).then(() => this.set('isDeleting', false));
    },

    toggleEdit() {
      this.set('isEditing', !this.isEditing);
      scheduleOnce('afterRender', this, function() {
        const input = this.element.querySelector('.textInput');
        input && input.focus();
      });
    },

    updateDocument() {
      this.set('isUpdating', true);
      this.onUpdate(this.document, this.renamedDocumentPath).then(() =>
        this.setProperties({isUpdating: false, isEditing: false})
      );
    }
  }
});
