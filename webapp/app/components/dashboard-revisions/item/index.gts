import {action} from '@ember/object';
import {readOnly, or} from '@ember/object/computed';
import Component from '@glimmer/component';
import percentage from 'accent-webapp/component-helpers/percentage';
import {tracked} from '@glimmer/tracking';
import {on} from '@ember/modifier';
import {fn, array, hash, get} from '@ember/helper';
import CheckSvg from 'accent-webapp/svgs/assets/check.svg';
import GearSvg from 'accent-webapp/svgs/assets/gear.svg';
import RevertSvg from 'accent-webapp/svgs/assets/revert.svg';
import TagSvg from 'accent-webapp/svgs/assets/tag.svg';
import {scopedClass} from 'ember-scoped-css';
import {LinkTo} from '@ember/routing';
import AccBadge from 'accent-webapp/components/acc-badge/index';
import t from 'ember-intl/helpers/t';
import ReviewProgressBar from 'accent-webapp/components/review-progress-bar/index';
import AsyncButton from 'accent-webapp/components/async-button/index';

const LOW_PERCENTAGE = 50;
const HIGH_PERCENTAGE = 90;

interface MainRevision {
  id: string;
  reviewedCount: number;
  translationsCount: number;
}

interface Args {
  project: any;
  revision: any;
  mainRevisions: MainRevision[];
  permissions: Record<string, true>;
  selectedDocument: string | null;
  selectedVersion: string | null;
  onCorrectAllConflicts: (revision: any) => Promise<void>;
  onUncorrectAllConflicts: (revision: any) => Promise<void>;
  onCorrectAllConflictsFromVersion: (revision: any) => Promise<void>;
}

export default class DashboardRevisionsItem extends Component<Args> {
  <template>
    <div
      class='dashboard-revisions-item
        {{if this.master "master"}}
        {{if this.lowPercentage "low-percentage"}}
        {{if this.mediumPercentage "medium-percentage"}}
        {{if this.highPercentage "high-percentage"}}'
    >
      <div class='item'>
        <button
          type='button'
          class='actionsButton'
          {{on 'click' (fn this.toggleShowActions)}}
        >
          <GearSvg class={{scopedClass 'actionsButton-icon'}} />
        </button>
        <span class='language'>
          <LinkTo
            @route='logged-in.project.revision.translations'
            @models={{array @project.id @revision.id}}
            @query={{hash document=@selectedDocument version=@selectedVersion}}
            class='language-name'
          >
            {{this.languageName}}
            {{#if this.rtl}}
              <AccBadge
                class='tooltip tooltip--top'
                title={{t 'components.dashboard_revisions.item.rtl'}}
              >
                {{t 'components.dashboard_revisions.item.rtl_badge'}}
              </AccBadge>
            {{/if}}
          </LinkTo>

          <span class='reviewedStats'>
            <span class='language-reviewedPercentage'>
              {{this.correctedKeysPercentage}}<span
                class='language-reviewedPercentage-symbol'
              >%</span>
            </span>

            <div>
              <LinkTo
                @route='logged-in.project.conflicts'
                @model={{@project.id}}
                class='reviewedStats-reviewedCount'
              >
                {{this.toReviewCount}}
                {{t 'components.dashboard_revisions.item.stats_to_review'}}
              </LinkTo>

              {{#unless @revision.isMaster}}
                <span class='reviewedStats-translatedCount'>
                  {{@revision.translatedCount}}
                  {{t 'components.dashboard_revisions.item.stats_translated'}}
                </span>
              {{/unless}}
            </div>
          </span>
        </span>

        <div class='progress'>
          <ReviewProgressBar
            @correctedKeysPercentage={{this.correctedKeysPercentage}}
          />
        </div>

        {{#if this.showActions}}
          <div class='actions'>
            {{#if (get @permissions 'correctAllRevision')}}
              {{#if this.showCorrectAllAction}}
                <AsyncButton
                  @onClick={{fn this.correctAllConflicts}}
                  @loading={{this.isCorrectAllConflictLoading}}
                  @disabled={{this.isAnyActionsLoading}}
                  class='button button--green button--highlight button--borderless actionItem-button'
                >
                  <CheckSvg class='button-icon' />
                  {{t 'components.dashboard_revisions.item.correct_all_button'}}
                </AsyncButton>
              {{/if}}
              {{#if this.showCorrectAllFromVersionAction}}
                <AsyncButton
                  @onClick={{fn this.correctAllConflictsFromVersion}}
                  @loading={{this.isCorrectAllFromVersionLoading}}
                  @disabled={{this.isAnyActionsLoading}}
                  class='button button--blue button--highlight button--borderless actionItem-button'
                >
                  <TagSvg class='button-icon' />
                  {{t
                    'components.dashboard_revisions.item.correct_all_from_version_button'
                  }}
                  <span
                    class='actionItem-percentage'
                  >{{this.mainRevisionReviewedPercentage}}%</span>
                </AsyncButton>
              {{/if}}
            {{/if}}
            {{#if (get @permissions 'uncorrectAllRevision')}}
              {{#if this.showUncorrectAllAction}}
                <AsyncButton
                  @onClick={{fn this.uncorrectAllConflicts}}
                  @loading={{this.isUncorrectAllConflictLoading}}
                  @disabled={{this.isAnyActionsLoading}}
                  class='button button--red button--highlight button--borderless actionItem-button'
                >
                  <RevertSvg class='button-icon' />
                  {{t
                    'components.dashboard_revisions.item.uncorrect_all_button'
                  }}
                </AsyncButton>
              {{/if}}
            {{/if}}
          </div>
        {{/if}}
      </div>
    </div>

    <style scoped>
      .dashboard-revisions-item {
        transition: 0.2s ease-in-out;
        transition-property: box-shadow;
        position: relative;
        justify-content: space-between;
        width: 100%;
        margin-bottom: 10px;
      }

      .dashboard-revisions-item.low-percentage .language-reviewedPercentage {
        color: var(--color-error);
      }
      .dashboard-revisions-item.low-percentage .progress {
        color: var(--color-error);
      }

      .dashboard-revisions-item.medium-percentage .language-reviewedPercentage {
        color: var(--color-warning);
      }
      .dashboard-revisions-item.medium-percentage .progress {
        color: var(--color-warning);
      }

      .dashboard-revisions-item.high-percentage .language-reviewedPercentage {
        color: var(--color-success);
      }
      .dashboard-revisions-item.high-percentage .progress {
        color: var(--color-success);
      }

      .dashboard-revisions-item.master {
        flex: 1 1 auto;
        max-width: none;
        margin-right: 0;
        border-radius: var(--border-radius);
        box-shadow:
          0 6px 25px var(--shadow-color),
          0 2px 7px var(--shadow-color);
      }
      .dashboard-revisions-item.master .language-name {
        font-size: 14px;
      }
      .dashboard-revisions-item.master .item {
        padding: 8px 10px;
      }

      .item {
        padding: 8px 2px;
      }

      .language {
        display: flex;
        flex-direction: column;
        color: var(--color-grey);
      }

      .language-name {
        transition: 0.2s ease-in-out;
        transition-property: color;
        font-size: 12px;
        text-decoration: none;
        color: var(--color-black);
        font-weight: bold;
      }
      .language-name:focus,
      .language-name:hover {
        color: var(--color-primary);
      }

      .language-reviewedPercentage {
        display: flex;
        align-items: baseline;
        gap: 4px;
        font-weight: normal;
        font-size: 22px;
        color: var(--color-grey);
        letter-spacing: -2px;
      }

      .language-reviewedPercentage-symbol {
        font-size: 13px;
      }

      .reviewedStats {
        display: flex;
        align-items: baseline;
        justify-content: space-between;
        gap: 10px;
        color: var(--color-grey);
        font-size: 12px;
        font-family: var(--font-monospace);
      }

      .reviewedStats-translatedCount,
      .reviewedStats-translationsCount,
      .reviewedStats-reviewedCount {
        font-family: var(--font-primary);
        color: var(--color-grey);
        margin: 0 3px;
        font-size: 11px;
        text-decoration: none;
      }

      .reviewedStats-reviewedCount {
        font-weight: bold;
      }

      .actionsButton {
        transition: 0.2s ease-in-out;
        transition-property: opacity;
        position: absolute;
        right: 3px;
        top: 3px;
        display: flex;
        align-items: center;
        justify-content: center;
        width: 24px;
        height: 24px;
        background: var(--content-background);
        cursor: pointer;
      }
      .actionsButton:focus .actionsButton-icon,
      .actionsButton:hover .actionsButton-icon {
        opacity: 1;
      }

      .actionsButton-icon {
        stroke: var(--color-grey);
        opacity: 0.4;
        transition: 0.2s ease-in-out;
        transition-property: stroke, opacity;
        width: 13px;
        height: 13px;
      }

      .actions {
        margin: 10px 0 0;
        display: flex;
        flex-direction: column;
        gap: 4px;
      }
      .actions :global(.button) {
        justify-content: center;
      }

      .actionItem-text {
        font-size: 12px;
        color: var(--color-grey);
      }

      .actionItem-percentage {
        opacity: 0.7;
        font-weight: normal;
        font-family: var(--font-monospace);
      }

      @media (max-width: 440px) {
        .language-reviewedPercentage {
          font-size: 18px;
        }
        .reviewedStats {
          display: none;
        }
      }
    </style>
  </template>
  @readOnly('args.revision.isMaster')
  master: boolean;

  @or(
    'isCorrectAllConflictLoading',
    'isUncorrectAllConflictLoading',
    'isCorrectAllFromVersionLoading'
  )
  isAnyActionsLoading: boolean;

  @tracked
  showActions = false;

  @tracked
  isCorrectAllConflictLoading = false;

  @tracked
  isUncorrectAllConflictLoading = false;

  @tracked
  isCorrectAllFromVersionLoading = false;

  get showCorrectAllAction() {
    return this.correctedKeysPercentage < 100;
  }

  get showUncorrectAllAction() {
    return this.correctedKeysPercentage > 0;
  }

  get mainRevision() {
    return this.args.mainRevisions?.find(
      (r: MainRevision) => r.id === this.args.revision.id
    );
  }

  get mainRevisionHasStringsToReview() {
    if (!this.mainRevision) return false;
    return (
      this.mainRevision.reviewedCount < this.mainRevision.translationsCount
    );
  }

  get mainRevisionReviewedPercentage() {
    if (!this.mainRevision || this.mainRevision.translationsCount === 0)
      return 100;
    return percentage(
      this.mainRevision.reviewedCount,
      this.mainRevision.translationsCount
    );
  }

  get showCorrectAllFromVersionAction() {
    return this.args.selectedVersion && this.mainRevisionHasStringsToReview;
  }

  get lowPercentage() {
    return this.correctedKeysPercentage < LOW_PERCENTAGE;
  }

  get mediumPercentage() {
    return this.correctedKeysPercentage >= LOW_PERCENTAGE;
  }

  get highPercentage() {
    return this.correctedKeysPercentage >= HIGH_PERCENTAGE;
  }

  get correctedKeysPercentage() {
    return percentage(
      this.args.revision.translationsCount - this.args.revision.conflictsCount,
      this.args.revision.translationsCount
    );
  }

  get toReviewCount() {
    const {reviewedCount, translationsCount} = this.args.revision;

    return translationsCount - reviewedCount;
  }

  get languageName() {
    return this.args.revision.name || this.args.revision.language.name;
  }

  get rtl() {
    return this.args.revision.rtl || this.args.revision.language.rtl;
  }

  @action
  toggleShowActions() {
    this.showActions = !this.showActions;
  }

  @action
  async correctAllConflicts() {
    this.isCorrectAllConflictLoading = true;

    await this.args.onCorrectAllConflicts(this.args.revision);

    this.onCorrectAllConflictsDone();
  }

  @action
  async uncorrectAllConflicts() {
    this.isUncorrectAllConflictLoading = true;

    await this.args.onUncorrectAllConflicts(this.args.revision);

    this.onUncorrectAllConflictsDone();
  }

  @action
  async correctAllConflictsFromVersion() {
    this.isCorrectAllFromVersionLoading = true;

    await this.args.onCorrectAllConflictsFromVersion(this.args.revision);

    this.onCorrectAllFromVersionDone();
  }

  private onCorrectAllConflictsDone() {
    this.isCorrectAllConflictLoading = false;
  }

  private onUncorrectAllConflictsDone() {
    this.isUncorrectAllConflictLoading = false;
  }

  private onCorrectAllFromVersionDone() {
    this.isCorrectAllFromVersionLoading = false;
  }
}
