import {computed} from '@ember/object';
import {alias, lt, gte, or, gt} from '@ember/object/computed';
import Component from '@ember/component';
import percentage from 'accent-webapp/component-helpers/percentage';

const LOW_PERCENTAGE = 50;
const HIGH_PERCENTAGE = 90;

// Attributes:
// project: Object <project>
// revision: Object <revision>
// permissions: Ember Object containing <permission>
// onCorrectAllConflicts: Function
// onUncorrectAllConflicts: Function
export default Component.extend({
  showActions: false,
  master: alias('revision.isMaster'),
  lowPercentage: lt('correctedKeysPercentage', LOW_PERCENTAGE), // Lower than low percentage
  mediumPercentage: gte('correctedKeysPercentage', LOW_PERCENTAGE), // higher or equal than low percentage
  highPercentage: gte('correctedKeysPercentage', HIGH_PERCENTAGE), // higher or equal than high percentage

  classNameBindings: [
    'master',
    'lowPercentage',
    'mediumPercentage',
    'highPercentage'
  ],

  isCorrectAllConflictLoading: false,
  isUncorrectAllConflictLoading: false,

  isAnyActionsLoading: or(
    'isCorrectAllConflictLoading',
    'isUncorrectAllConflictLoading'
  ),

  showCorrectAllAction: lt('correctedKeysPercentage', 100),
  showUncorrectAllAction: gt('correctedKeysPercentage', 0),

  correctedKeysPercentage: computed(
    'revision.{conflictsCount,translationsCount}',
    function() {
      return percentage(
        this.revision.translationsCount - this.revision.conflictsCount,
        this.revision.translationsCount
      );
    }
  ),

  reviewsCount: computed(
    'revision.{conflictsCount,translationsCount}',
    function() {
      const {conflictsCount, translationsCount} = this.revision;

      return translationsCount - conflictsCount;
    }
  ),

  actions: {
    toggleShowActions() {
      this.toggleProperty('showActions');
    },

    correctAllConflicts() {
      this.set('isCorrectAllConflictLoading', true);

      this.onCorrectAllConflicts(this.revision).then(() =>
        this._onCorrectAllConflictsDone()
      );
    },

    uncorrectAllConflicts() {
      this.set('isUncorrectAllConflictLoading', true);

      this.onUncorrectAllConflicts(this.revision).then(() =>
        this._onUncorrectAllConflictsDone()
      );
    }
  },

  _onCorrectAllConflictsDone() {
    this.set('isCorrectAllConflictLoading', false);
  },

  _onUncorrectAllConflictsDone() {
    this.set('isUncorrectAllConflictLoading', false);
  }
});
