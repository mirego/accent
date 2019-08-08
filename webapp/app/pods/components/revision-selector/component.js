import {computed} from '@ember/object';
import {inject as service} from '@ember/service';
import {htmlSafe} from '@ember/string';
import Component from '@ember/component';

// Attributes:
// revision: Object <revision>
// onSelect: Function
export default Component.extend({
  i18n: service(),
  globalState: service('global-state'),

  classNameBindings: ['hasManyRevisions:with-many-revisions'],

  withRevisionsCount: true,

  hasManyRevisions: computed('revisions.[]', function() {
    return this.revisions && this.revisions.length > 1;
  }),

  revisionValue: computed('revision', 'revisions.[]', function() {
    return this.mappedRevisions.find(({value}) => value === this.revision);
  }),

  mappedRevisions: computed('revisions.[]', function() {
    return this.revisions.map(({id, name, isMaster, language}) => {
      const masterLabel = name =>
        htmlSafe(
          `${name} <em>${this.i18n.t(
            'components.revision_selector.master'
          )}</em>`
        );
      const displayName = name || language.name;
      const label = isMaster ? masterLabel(displayName) : displayName;

      return {label, value: id};
    });
  }),

  otherRevisionsCount: computed('revisions.length', function() {
    return this.revisions && this.revisions.length - 1;
  }),

  actions: {
    selectRevision(value) {
      this.set('globalState.revision', value);

      this.onSelect(value);
    }
  }
});
