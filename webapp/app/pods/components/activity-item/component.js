import {computed} from '@ember/object';
import {inject as service} from '@ember/service';
import {readOnly, reads, equal} from '@ember/object/computed';
import Component from '@ember/component';
import {underscore, dasherize} from '@ember/string';

import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';

/* eslint camelcase:0 */
const ACTIONS_ICON_PATHS = {
  version_new: 'assets/tag.svg',
  add_to_version: 'assets/tag.svg',
  create_version: 'assets/tag.svg',
  sync: 'assets/sync.svg',
  merge: 'assets/merge.svg',
  rollback: 'assets/revert.svg',
  update: 'assets/pencil.svg',
  correct_conflict: 'assets/check.svg',
  correct_all: 'assets/check.svg',
  uncorrect_all: 'assets/revert.svg',
  uncorrect_conflict: 'assets/revert.svg',
  conflict_on_slave: 'assets/x.svg',
  conflict_on_corrected: 'assets/x.svg',
  conflict_on_proposed: 'assets/x.svg',
  remove: 'assets/x.svg',
  new_comment: 'assets/bubble.svg',
  new_slave: 'assets/language.svg',
  document_delete: 'assets/file.svg'
};

// Attributes:
// project: Object <project>
// permissions: Ember Object containing <permission>
// showTranslationLink: Boolean
// activity: Object <project-activity>
// componentTranslationPrefix: String
export default Component.extend({
  intl: service('intl'),

  classNameBindings: ['compact', 'activityItemClassName', 'rollbacked'],

  action: readOnly('activity.action'),
  rollbacked: reads('activity.isRollbacked'),
  rollbackedOperationHasEmptyText: equal(
    'activity.rollbackedOperation.valueType',
    'EMPTY'
  ),
  hasEmptyText: equal('activity.valueType', 'EMPTY'),

  translationKey: parsedKeyProperty('activity.translation.key'),

  activityItemClassName: computed('activity.action', function() {
    return dasherize(this.activity.action);
  }),

  actionText: computed('action', function() {
    return this._getActionText(this.action);
  }),

  rollbackedOperationActionText: computed(
    'activity.rollbackedOperation.action',
    function() {
      return this._getActionText(this.activity.rollbackedOperation.action);
    }
  ),

  showFromOperationTranslationLink: computed(
    'showTranslationLink',
    'activity.rollbackedOperation.translation.id',
    function() {
      return (
        this.showTranslationLink &&
        this.activity.rollbackedOperation &&
        this.activity.rollbackedOperation.translation &&
        this.activity.rollbackedOperation.translation.id
      );
    }
  ),

  showStats: computed('activity.stats.[]', function() {
    return this.activity.stats;
  }),

  localizedStats: computed('activity.stats.[]', function() {
    return this.activity.stats.map(stat => {
      const text = this.intl.t(
        `components.${this.componentTranslationPrefix}.stats_text.${underscore(
          stat.action
        )}`
      );
      const count = stat.count;

      return {text, count};
    });
  }),

  statsLabel: computed('componentTranslationPrefix', function() {
    return this.intl.t(
      `components.${this.componentTranslationPrefix}.stats_label_text`
    );
  }),

  showDocumentInfo: computed('action', 'activity.document.path', function() {
    const action = this.action;
    const actionsWithDocument = ['sync', 'document_delete', 'merge'];

    return (
      actionsWithDocument.includes(action) && readOnly('activity.document.path')
    );
  }),

  showVersionInfo: readOnly('activity.version.id'),

  revisionName: computed('activity.revision.{name,language.name}', function() {
    return this.activity.revision.name || this.activity.revision.language.name;
  }),

  showRevisionInfo: computed(
    'action',
    'activity.revision.language.id',
    function() {
      if (!this.activity.revision) return false;

      const actionsWithRevision = [
        'new',
        'remove',
        'renew',
        'new_slave',
        'merge',
        'uncorrect_all',
        'correct_all',
        'batch_correct_conflict',
        'batch_update',
        'conflict_on_slave'
      ];

      return (
        actionsWithRevision.includes(this.action) &&
        this.activity.revision.language.id
      );
    }
  ),

  showFromOperationDocumentInfo: computed(
    'activity.rollbackedOperation.{action,document.path}',
    function() {
      const action = this.activity.rollbackedOperation.action;
      const actionsWithDocument = ['sync', 'document_delete', 'merge'];

      return (
        actionsWithDocument.includes(action) &&
        readOnly('activity.rollbackedOperation.document.path')
      );
    }
  ),

  isShowingTranslationLink: computed(
    'showTranslationLink',
    'activity.{action,translation}',
    function() {
      return (
        this.showTranslationLink &&
        this.activity.translation &&
        this.activity.action !== 'rollback'
      );
    }
  ),

  iconPath: computed('action', function() {
    return ACTIONS_ICON_PATHS[this.action] || 'assets/add.svg';
  }),

  _getActionText(action) {
    return this.intl.t(
      `components.${this.componentTranslationPrefix}.action_text.${action}`
    );
  }
});
