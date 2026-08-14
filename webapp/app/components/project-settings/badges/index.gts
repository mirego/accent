import fmt from 'simple-fmt';
import Component from '@glimmer/component';
import {htmlSafe} from '@ember/template';
import config from 'accent-webapp/config/environment';
import Title from 'accent-webapp/components/project-settings/title/index';
import t from 'ember-intl/helpers/t';
import {concat} from '@ember/helper';

const {API} = config;

interface Args {
  project: any;
}

export default class Badges extends Component<Args> {
  <template>
    <div class='project-settings-badges'>
      <Title @title={{t 'components.project_settings.badges.title'}} />

      <p class='text'>
        {{t 'components.project_settings.badges.text'}}
      </p>

      <div class='badge-item'>
        <div class='badge'>
          <span class='badge-title'>
            {{t 'components.project_settings.badges.percentage_reviewed'}}
          </span>

          <img
            src={{concat
              this.percentageReviewedBadgeUrl
              '?digest='
              this.digest
            }}
          />
        </div>

        <input
          readonly
          onClick='this.select();'
          value={{this.percentageReviewedBadgeCode}}
          class='badge-code'
        />
      </div>

      <div class='badge-item'>
        <div class='badge'>
          <span class='badge-title'>
            {{t 'components.project_settings.badges.translations'}}
          </span>

          <img
            src={{concat this.translationsBadgeUrl '?digest=' this.digest}}
          />
        </div>

        <input
          readonly
          onClick='this.select();'
          value={{this.translationsBadgeCode}}
          class='badge-code'
        />
      </div>

      <div class='badge-item'>
        <div class='badge'>
          <span class='badge-title'>
            {{t 'components.project_settings.badges.reviewed'}}
          </span>

          <img src={{concat this.reviewedBadgeUrl '?digest=' this.digest}} />
        </div>

        <input
          readonly
          onClick='this.select();'
          value={{this.reviewedBadgeCode}}
          class='badge-code'
        />
      </div>

      <div class='badge-item'>
        <div class='badge'>
          <span class='badge-title'>
            {{t 'components.project_settings.badges.conflicts'}}
          </span>
          <img src={{concat this.conflictsBadgeUrl '?digest=' this.digest}} />
        </div>

        <input
          readonly
          onClick='this.select();'
          value={{this.conflictsBadgeCode}}
          class='badge-code'
        />
      </div>
    </div>

    <style scoped>
      .project-settings-badges {
        margin-top: 30px;
      }

      .text {
        max-width: 490px;
        margin: 10px 0 15px;
        font-size: 13px;
        font-style: italic;
      }

      .badge-item {
        margin-bottom: 20px;
      }

      .badge {
        display: flex;
        justify-content: flex-start;
        align-items: center;
      }

      .badge-title {
        margin: 0 10px 0 0;
        font-size: 14px;
        font-weight: bold;
        color: var(--color-black);
      }

      .badge-code {
        display: inline-block;
        width: 100%;
        margin: 10px 0 0;
        padding: 8px;
        overflow-x: scroll;
        word-break: keep-all;
        font-family: var(--font-monospace);
        font-size: 11px;
        background: var(--background-light);
        border: 2px solid var(--background-light-highlight);
        border-radius: var(--border-radius);
        transition-property: border-color, box-shadow;
        transition: 0.3s ease-in-out;
        color: var(--color-black);
      }
      .badge-code:focus {
        outline: none;
        border-color: color-mix(in srgb, var(--color-primary) 70%, transparent);
        box-shadow: 0 0 3px 2px
          color-mix(in srgb, var(--color-primary) 10%, transparent);
      }
      .badge-code:focus::-moz-selection {
        background: color-mix(in srgb, var(--color-primary) 10%, transparent);
      }
      .badge-code:focus::selection {
        background: color-mix(in srgb, var(--color-primary) 10%, transparent);
      }
    </style>
  </template>
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
