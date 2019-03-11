import {computed} from '@ember/object';
import {lt, gte} from '@ember/object/computed';
import Component from '@ember/component';
import percentage from 'accent-webapp/component-helpers/percentage';

const LOW_PERCENTAGE = 50;
const HIGH_PERCENTAGE = 90;

// Attributes:
// project: Object <project>
// document: Object <document>
// revisions: Array of <revision>
// permissions: Ember Object containing <permission>
// onCorrectAllConflicts: Function
// onUncorrectAllConflicts: Function
export default Component.extend({
  lowPercentage: lt('reviewedPercentage', LOW_PERCENTAGE), // Lower than low percentage
  mediumPercentage: gte('reviewedPercentage', LOW_PERCENTAGE), // higher or equal than low percentage
  highPercentage: gte('reviewedPercentage', HIGH_PERCENTAGE), // higher or equal than high percentage

  classNameBindings: ['lowPercentage', 'mediumPercentage', 'highPercentage'],

  masterRevision: computed('revisions', function() {
    return this.revisions.find(revision => revision.isMaster);
  }),

  slaveRevisions: computed('revisions', function() {
    return this.revisions.filter(revision => revision !== this.masterRevision);
  }),

  totalStrings: computed('revisions.[]', function() {
    return this.revisions.reduce((memo, revision) => {
      return memo + revision.translationsCount;
    }, 0);
  }),

  totalConflicts: computed('revisions.[]', function() {
    return this.revisions.reduce((memo, revision) => {
      return memo + revision.conflictsCount;
    }, 0);
  }),

  totalReviewed: computed('revisions.[]', function() {
    return this.revisions.reduce((memo, revision) => {
      return memo + (revision.translationsCount - revision.conflictsCount);
    }, 0);
  }),

  reviewCompleted: gte('reviewedPercentage', 100),

  reviewedPercentage: computed('totalConflicts', 'totalStrings', function() {
    return percentage(
      this.totalStrings - this.totalConflicts,
      this.totalStrings
    );
  }),

  conflictedPercentage: computed('totalReviewed', 'totalStrings', function() {
    return percentage(
      this.totalStrings - this.totalReviewed,
      this.totalStrings
    );
  })
});
