import {computed} from '@ember/object';
import {alias, lt, gte} from '@ember/object/computed';
import Component from '@ember/component';
import percentage from 'accent-webapp/component-helpers/percentage';

const LOW_PERCENTAGE = 50;
const HIGH_PERCENTAGE = 90;

interface Args {}

// Attributes:
// project: Object <project>
// revision: Object <revision>
// permissions: Ember Object containing <permission>

export default class DashboardRevisionProgress extends Component<Args> {
  // master: alias('revision.master'),
  // lowPercentage: lt('correctedKeysPercentage', LOW_PERCENTAGE), // Lower than low percentage
  // mediumPercentage: gte('correctedKeysPercentage', LOW_PERCENTAGE), // higher or equal than low percentage
  // highPercentage: gte('correctedKeysPercentage', HIGH_PERCENTAGE), // higher or equal than high percentage
  // classNameBindings: [
  //   'master',
  //   'lowPercentage',
  //   'mediumPercentage',
  //   'highPercentage'
  // ],
  // correctedKeysPercentage: computed(
  //   'revision.{conflictsCount,translationsCount}',
  //   function() {
  //     const {conflictsCount, translationsCount} = this.revision;
  //     return percentage(conflictsCount, translationsCount);
  //   }
  // ),
  // reviewsCount: computed(
  //   'revision.{conflictsCount,translationsCount}',
  //   function() {
  //     const {conflictsCount, translationsCount} = this.revision;
  //     return translationsCount - conflictsCount;
  //   }
  // )
}
