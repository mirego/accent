import fmt from 'npm:simple-fmt';
import Component from '@ember/component';
import {computed} from '@ember/object';
import {htmlSafe} from '@ember/string';
import config from 'accent-webapp/config/environment';

const {API} = config;

export default Component.extend({
  projectUrl: computed('project.id', function() {
    return fmt(API.PROJECT_PATH, this.project.id);
  }),

  percentageReviewedBadgeCode: computed(
    'percentageReviewedBadgeUrl',
    'projectUrl',
    function() {
      // eslint-disable-next-line no-irregular-whitespace
      return htmlSafe(
        `![strings reviewed status](${this.percentageReviewedBadgeUrl})](${
          this.projectUrl
        })`
      );
    }
  ),

  percentageReviewedBadgeUrlWithDigest: computed(
    'percentageReviewedBadgeUrl',
    function() {
      return `${
        this.percentageReviewedBadgeUrl
      }?digest=${new Date().getTime()}`;
    }
  ),

  percentageReviewedBadgeUrl: computed('project.id', function() {
    return fmt(API.PERCENTAGE_REVIEWED_BADGE_SVG_PROJECT_PATH, this.project.id);
  })
});
