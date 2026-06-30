import {action} from '@ember/object';
import {readOnly, or} from '@ember/object/computed';
import Component from '@glimmer/component';
import percentage from 'accent-webapp/component-helpers/percentage';
import {tracked} from '@glimmer/tracking';
import {on} from '@ember/modifier';
import {fn, array, hash, get} from '@ember/helper';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
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
        <span
          role='button'
          class='actionsButton'
          {{on 'click' (fn this.toggleShowActions)}}
        >
          {{inlineSvg
            'assets/gear.svg'
            class=(scopedClass 'actionsButton-icon')
          }}
        </span>
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
                  {{inlineSvg '/assets/check.svg' class='button-icon'}}
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
                  {{inlineSvg '/assets/tag.svg' class='button-icon'}}
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
                  {{inlineSvg '/assets/revert.svg' class='button-icon'}}
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
