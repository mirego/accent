import Component from '@glimmer/component';
import {lt, gte} from '@ember/object/computed';
import percentage from 'accent-webapp/component-helpers/percentage';

const LOW_PERCENTAGE = 50;
const HIGH_PERCENTAGE = 90;

interface Args {
  project: any;
}

export default class ProjectsListItem extends Component<Args> {
  @lt('correctedKeysPercentage', LOW_PERCENTAGE)
  lowPercentage: boolean; // Lower than low percentage

  @gte('correctedKeysPercentage', LOW_PERCENTAGE)
  mediumPercentage: boolean; // higher or equal than low percentage

  @gte('correctedKeysPercentage', HIGH_PERCENTAGE)
  highPercentage: boolean; // higher or equal than high percentage

  get colors() {
    return `
      .projectId-${this.args.project.id} {
        --color-primary: ${this.args.project.mainColor};
      }
    `;
  }

  get totalStrings() {
    return this.args.project.translationsCount;
  }

  get totalConflicts() {
    return this.args.project.conflictsCount;
  }

  get totalReviewed() {
    return (
      this.args.project.translationsCount - this.args.project.conflictsCount
    );
  }

  get correctedKeysPercentage() {
    return percentage(
      this.totalStrings - this.totalConflicts,
      this.totalStrings
    );
  }
}
