import Component from '@ember/component';
import {computed} from '@ember/object';
import {readOnly, lt, gte} from '@ember/object/computed';
import percentage from 'accent-webapp/component-helpers/percentage';

const LOW_PERCENTAGE = 50;
const HIGH_PERCENTAGE = 90;

// Attributes:
// project: Object <project>
export default Component.extend({
  revisions: readOnly('project.revisions'),

  lowPercentage: lt('correctedKeysPercentage', LOW_PERCENTAGE), // Lower than low percentage
  mediumPercentage: gte('correctedKeysPercentage', LOW_PERCENTAGE), // higher or equal than low percentage
  highPercentage: gte('correctedKeysPercentage', HIGH_PERCENTAGE), // higher or equal than high percentage

  classNameBindings: ['lowPercentage', 'mediumPercentage', 'highPercentage'],

  colors: computed('project.mainColor', function() {
    return `
      .projectId-${this.project.id} {
        --color-primary: ${this.project.mainColor};
      }
    `;
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

  correctedKeysPercentage: computed(
    'totalConflicts',
    'totalStrings',
    function() {
      return percentage(
        this.totalStrings - this.totalConflicts,
        this.totalStrings
      );
    }
  )
});
