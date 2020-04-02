import fmt from 'simple-fmt';
import Component from '@glimmer/component';
import {htmlSafe} from '@ember/string';
import config from 'accent-webapp/config/environment';

const {API} = config;

interface Args {
  project: any;
}

export default class Badges extends Component<Args> {
  get projectUrl() {
    return fmt(API.PROJECT_PATH, this.args.project.id);
  }

  get percentageReviewedBadgeCode() {
    // eslint-disable-next-line no-irregular-whitespace
    return htmlSafe(
      `![strings reviewed status](${this.percentageReviewedBadgeUrl})](${this.projectUrl})`
    );
  }

  get percentageReviewedBadgeUrlWithDigest() {
    return `${this.percentageReviewedBadgeUrl}?digest=${new Date().getTime()}`;
  }

  get percentageReviewedBadgeUrl() {
    return fmt(
      API.PERCENTAGE_REVIEWED_BADGE_SVG_PROJECT_PATH,
      this.args.project.id
    );
  }
}
