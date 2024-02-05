import fmt from 'simple-fmt';
import Component from '@glimmer/component';
import {htmlSafe} from '@ember/template';
import config from 'accent-webapp/config/environment';

const {API} = config;

interface Args {
  project: any;
}

export default class Badges extends Component<Args> {
  digest = new Date().getTime();

  get projectUrl() {
    return fmt(API.PROJECT_PATH, this.args.project.id);
  }

  get percentageReviewedBadgeCode() {
    // eslint-disable-next-line no-irregular-whitespace
    return htmlSafe(
      `![Strings reviewed status](${this.percentageReviewedBadgeUrl})](${this.projectUrl})`
    );
  }

  get percentageReviewedBadgeUrl() {
    const host = window.location.origin;
    const path = config.API.PERCENTAGE_REVIEWED_BADGE_SVG_PROJECT_PATH;

    return `${host}${fmt(path, this.args.project.id)}`;
  }

  get translationsBadgeCode() {
    // eslint-disable-next-line no-irregular-whitespace
    return htmlSafe(
      `![Translations](${this.translationsBadgeUrl})](${this.projectUrl})`
    );
  }

  get translationsBadgeUrl() {
    const host = window.location.origin;
    const path = config.API.TRANSLATIONS_BADGE_SVG_PROJECT_PATH;

    return `${host}${fmt(path, this.args.project.id)}`;
  }

  get reviewedBadgeCode() {
    // eslint-disable-next-line no-irregular-whitespace
    return htmlSafe(
      `![Reviewed](${this.reviewedBadgeUrl})](${this.projectUrl})`
    );
  }

  get reviewedBadgeUrl() {
    const host = window.location.origin;
    const path = config.API.REVIEWED_BADGE_SVG_PROJECT_PATH;

    return `${host}${fmt(path, this.args.project.id)}`;
  }

  get conflictsBadgeCode() {
    // eslint-disable-next-line no-irregular-whitespace
    return htmlSafe(
      `![Conflicts](${this.conflictsBadgeUrl})](${this.projectUrl})`
    );
  }

  get conflictsBadgeUrl() {
    const host = window.location.origin;
    const path = config.API.CONFLICTS_BADGE_SVG_PROJECT_PATH;

    return `${host}${fmt(path, this.args.project.id)}`;
  }
}
