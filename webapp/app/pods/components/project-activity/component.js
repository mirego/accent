import {computed} from '@ember/object';
import {inject as service} from '@ember/service';
import {not, reads, equal} from '@ember/object/computed';
import Component from '@ember/component';
import {underscore} from '@ember/string';

import activityActivitiesQuery from 'accent-webapp/queries/activity-activities';
import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';

const ROLLBACKABLE_ACTIONS = [
  'sync',
  'merge',
  'document_delete',
  'uncorrect_all',
  'correct_all',
  'update',
  'correct_conflict',
  'uncorrect_conflict',
  'conflict_on_slave',
  'conflict_on_corrected',
  'conflict_on_proposed',
  'merge_on_proposed',
  'merge_on_corrected'
];

// componentTranslationPrefix: String
export default Component.extend({
  i18n: service(),
  apollo: service(),

  isRollbacking: false,
  canRollback: not('project.isFileOperationsLocked'),
  showStats: reads('activity.stats'),
  isRollbacked: reads('activity.isRollbacked'),
  isEmptyType: equal('activity.valueType', 'EMPTY'),
  previousTranslationIsEmptyType: equal('activity.previousTranslation.valueType', 'EMPTY'),
  operationsLoading: false,

  translationKey: parsedKeyProperty('activity.translation.key'),

  init() {
    this._super(...arguments);

    if (this.activity.isBatch && this.activity.action !== 'rollback') {
      this._fetchActivities(1);
    }
  },

  localizedStats: computed('activity.stats.[]', function() {
    return this.activity.stats.map(stat => {
      const text = this.i18n.t(`components.project_activity.stats_text.${underscore(stat.action)}`);
      const count = stat.count;

      return {text, count};
    });
  }),

  statsLabel: computed(function() {
    return this.i18n.t('components.project_activity.stats_label_text');
  }),

  actionExplanation: computed('activity.action', function() {
    if (!this.activity.action) return;

    return this.i18n.t(`components.project_activity.action_explanation.${this.activity.action}`);
  }),

  actionText: computed('activity.action', function() {
    if (!this.activity.action) return;

    return this.i18n.t(`components.project_activity.action_text.${this.activity.action}`);
  }),

  showTextDifferences: computed('activity.{text,previousTranslation.text}', function() {
    return (
      this.activity.previousTranslation &&
      this.activity.previousTranslation.text &&
      this.activity.text !== this.activity.previousTranslation.text &&
      this.activity.text !== null
    );
  }),

  showPreviousTranslationText: computed('activity.previousTranslation.{text,valueType}', function() {
    return this.activity.previousTranslation.text || this.activity.previousTranslation.valueType === 'EMPTY';
  }),

  showLastSyncedText: computed('activity.previousTranslation.{text,proposedText}', function() {
    return this.activity.previousTranslation.proposedText !== this.activity.previousTranslation.text;
  }),

  isRollbackable: computed('isRollbacked', 'activity.action', 'canRollback', function() {
    if (!this.onRollback) return false;
    if (!this.canRollback) return false;
    if (this.isRollbacked) return false;

    return ROLLBACKABLE_ACTIONS.indexOf(this.activity.action) !== -1;
  }),

  actions: {
    refreshActivities(page) {
      this._fetchActivities(page);
    },

    rollback() {
      /* eslint-disable no-alert */
      if (!window.confirm(this.i18n.t('components.project_activity.rollback_confirm'))) return;
      /* eslint-enable no-alert */

      this.set('isRollbacking', true);
      this.onRollback().then(() => this.set('isRollbacking', false));
    }
  },

  _fetchActivities(page) {
    this.set('operationsLoading', true);

    const variables = {
      projectId: this.project.id,
      activityId: this.activity.id,
      page
    };

    this.apollo.client
      .query({
        query: activityActivitiesQuery,
        variables
      })
      .then(({data}) => {
        const operations = data.viewer.project.activity.operations;

        this.set('operationsLoading', false);
        this.set('operations', operations);
      });
  }
});
