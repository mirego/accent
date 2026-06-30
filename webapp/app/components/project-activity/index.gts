import {action} from '@ember/object';
import {service} from '@ember/service';
import {not, readOnly, equal} from '@ember/object/computed';
import Component from '@glimmer/component';
import {underscore} from '@ember/string';
import activityActivitiesQuery from 'accent-webapp/queries/activity-activities';
import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';
import IntlService from 'ember-intl/services/intl';
import Apollo from 'accent-webapp/services/apollo';
import {tracked} from '@glimmer/tracking';
import didInsert from '@ember/render-modifiers/modifiers/did-insert';
import {fn, get, array} from '@ember/helper';
import t from 'ember-intl/helpers/t';
import TimeAgoInWordsTag from 'accent-webapp/components/time-ago-in-words-tag/index';
import AsyncButton from 'accent-webapp/components/async-button/index';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import arrayIncludes from 'accent-webapp/helpers/array-includes';
import {on} from '@ember/modifier';
import {scopedClass} from 'ember-scoped-css';
import {LinkTo} from '@ember/routing';
import stringDiff from 'accent-webapp/helpers/string-diff';
import ActivityItem from 'accent-webapp/components/activity-item/index';
import LoadingContent from 'accent-webapp/components/loading-content/index';
import ResourcePagination from 'accent-webapp/components/resource-pagination/index';

const ROLLBACKABLE_ACTIONS = [
  'sync',
  'merge',
  'document_delete',
  'uncorrect_all',
  'correct_all',
  'update',
  'correct_conflict',
  'uncorrect_conflict',
  'conflict_on_slave',
  'conflict_on_corrected',
  'conflict_on_proposed',
  'merge_on_proposed',
  'merge_on_corrected'
];

interface Args {
  permissions: Record<string, true>;
  showTranslationLink: boolean;
  componentTranslationPrefix: string;
  project: any;
  activity: any;
  onRollback: () => Promise<void>;
}

interface ActivityActivitiesData {
  viewer: {
    project: {
      activity: {
        operations: any;
      };
    };
  };
}

export default class ProjectActivity extends Component<Args> {
  <template>
    <div class='activity' {{didInsert (fn this.maybeFetchActivities)}}>
      <p class='activity-explanation'>
        <span class='activity-explanation-label'>
          {{t 'components.project_activity.explanation_label'}}
        </span>

        {{this.actionExplanation}}
      </p>

      <h1 class='activity-title'>
        <span class='activity-title-author'>
          {{@activity.user.fullname}}
        </span>

        {{this.actionText}}
      </h1>

      <div class='activity-meta'>
        <span class='activity-meta-info'>
          <span class='activity-date'><TimeAgoInWordsTag
              @date={{@activity.insertedAt}}
            /></span>

          {{#if this.gitBranch}}
            <span class='activity-git-branch'>
              <span class='activity-git-branch-label'>{{t
                  'components.project_activity.git_branch_label'
                }}</span>
              <span class='activity-git-branch-value'>{{this.gitBranch}}</span>
            </span>
          {{/if}}
        </span>

        {{#if this.isRollbacked}}
          <div class='rollbackedBadge'>
            {{t 'components.project_activity.rollbacked_label'}}
          </div>
        {{else if (get @permissions 'rollback')}}
          {{#if this.isRollbackable}}
            <AsyncButton
              @onClick={{fn this.rollback}}
              @loading={{this.isRollbacking}}
              class='button button--red button--borderless rollbackButton'
            >
              {{inlineSvg '/assets/revert.svg' class='button-icon'}}
              {{t 'components.project_activity.rollback'}}
            </AsyncButton>
          {{/if}}
        {{/if}}
      </div>
    </div>

    <div class='details'>
      <div class='details-states'>
        {{#if this.showStats}}
          <div class='stats'>
            <span class='details-label'>
              {{t 'components.project_activity.stats_label'}}
            </span>

            <div class='stats-items'>
              {{#each this.localizedStats as |stat|}}
                <button
                  type='button'
                  class='stats-item stats-item--clickable
                    {{if
                      (arrayIncludes this.selectedActions stat.action)
                      "stats-item--selected"
                    }}'
                  {{on 'click' (fn this.toggleAction stat.action)}}
                >
                  {{#if this.hasSelectedActions}}
                    <span
                      class='stats-checkbox
                        {{if
                          (arrayIncludes this.selectedActions stat.action)
                          "stats-checkbox--checked"
                        }}'
                    >
                      {{#if (arrayIncludes this.selectedActions stat.action)}}
                        {{inlineSvg
                          '/assets/check.svg'
                          class=(scopedClass 'stats-checkbox-icon')
                        }}
                      {{/if}}
                    </span>
                  {{/if}}
                  <span>
                    {{stat.text}}
                    :
                    <b>{{stat.count}}</b>
                  </span>
                </button>
              {{/each}}
            </div>
          </div>
        {{/if}}

        {{#if @activity.previousTranslation}}
          <div class='translation-state'>
            <span class='details-label'>
              {{t 'components.project_activity.details_label'}}
            </span>

            <div class='translation-state-items'>
              {{#if @activity.translation.key}}
                <div class='translation-state-item'>
                  <span class='translation-state-label'>
                    {{t 'components.project_activity.key_label'}}
                  </span>
                  <LinkTo
                    @route='logged-in.project.translation'
                    @models={{array @project.id @activity.translation.id}}
                    class='translation-state-key'
                  >
                    <small class='translation-state-key-prefix'>
                      {{#if this.translationKey.prefix}}
                        {{this.translationKey.prefix}}
                      {{else}}
                        {{@translation.document.path}}
                      {{/if}}
                    </small>
                    {{this.translationKey.value}}
                  </LinkTo>
                </div>
              {{/if}}

              {{#if @activity.document}}
                <div class='translation-state-item'>
                  <span class='translation-state-label'>
                    {{t 'components.project_activity.file_label'}}
                  </span>
                  <strong class='translation-state-document'>
                    {{@activity.document.path}}
                    (
                    {{@activity.document.format}}
                    )
                  </strong>
                </div>
              {{/if}}

              <div class='translation-state-item'>
                <span class='translation-state-label'>
                  {{t 'components.project_activity.review_label'}}
                </span>

                <strong class='translation-state-reviewed'>
                  {{#if @activity.previousTranslation.isConflicted}}
                    {{t 'components.project_activity.reviewed_no'}}
                  {{else}}
                    {{t 'components.project_activity.reviewed_yes'}}
                  {{/if}}
                </strong>
              </div>

              {{#if this.showLastSyncedText}}
                <div class='translation-state-item'>
                  <span class='translation-state-label'>
                    {{t 'components.project_activity.last_synced_text_label'}}
                  </span>

                  {{#if this.previousTranslationIsEmptyType}}
                    <strong
                      class='translation-state-value translation-state-value--empty'
                    >{{t 'components.project_activity.empty_value'}}</strong>
                  {{else}}
                    <strong
                      class='translation-state-value'
                    >{{@activity.previousTranslation.proposedText}}</strong>
                  {{/if}}
                </div>
              {{/if}}

              {{#if this.showPreviousTranslationText}}
                <div class='translation-state-item'>
                  <span class='translation-state-label'>
                    {{t 'components.project_activity.text_before_action_label'}}
                  </span>

                  {{#if this.previousTranslationIsEmptyType}}
                    <strong
                      class='translation-state-value translation-state-value--empty'
                    >{{t 'components.project_activity.empty_value'}}</strong>
                  {{else}}
                    <strong
                      class='translation-state-value'
                    >{{@activity.previousTranslation.text}}</strong>
                  {{/if}}
                </div>
              {{/if}}

              <div class='translation-state-item'>
                <span class='translation-state-label'>
                  {{t 'components.project_activity.new_text_label'}}
                </span>

                {{#if this.isEmptyType}}
                  <strong
                    class='translation-state-value translation-state-value--empty'
                  >{{t 'components.project_activity.empty_value'}}</strong>
                {{else}}
                  <strong
                    class='translation-state-value'
                  >{{@activity.text}}</strong>
                {{/if}}
              </div>

              {{#if this.showTextDifferences}}
                <div class='translation-state-item'>
                  <span class='translation-state-label'>
                    {{t 'components.project_activity.text_differences_label'}}
                  </span>
                  <strong class='translation-state-value'><div
                      class='textDiff'
                    >{{stringDiff
                        @activity.text
                        @activity.previousTranslation.text
                      }}</div></strong>
                </div>
              {{/if}}
            </div>
          </div>
        {{/if}}
      </div>

      <div class='details-associations'>
        {{#if @activity.rollbackedOperation}}
          <span class='details-label'>
            {{t 'components.project_activity.rollbacked_operation_label'}}
          </span>
          <ActivityItem
            @permissions={{@permissions}}
            @showTranslationLink={{true}}
            @componentTranslationPrefix='project_activities_list_item'
            @project={{@project}}
            @activity={{@activity.rollbackedOperation}}
          />
        {{/if}}

        {{#if @activity.rollbackOperation}}
          <span class='details-label'>
            {{t 'components.project_activity.rollback_operation_label'}}
          </span>
          <ActivityItem
            @permissions={{@permissions}}
            @showTranslationLink={{true}}
            @componentTranslationPrefix='translation_activities_list_item'
            @project={{@project}}
            @activity={{@activity.rollbackOperation}}
          />
        {{/if}}

        {{#if @activity.batchOperation}}
          <span class='details-label'>
            {{t 'components.project_activity.batch_operation_label'}}
          </span>
          <ActivityItem
            @permissions={{@permissions}}
            @showTranslationLink={{true}}
            @componentTranslationPrefix='project_activities_list_item'
            @project={{@project}}
            @activity={{@activity.batchOperation}}
          />
          <br />
        {{/if}}

        {{#if this.operationsLoading}}
          <LoadingContent
            @label={{t 'pods.project.activities.show.loading_activities'}}
          />
        {{else if this.operations.entries.length}}
          <span class='details-label'>
            {{t 'components.project_activity.operations_label'}}
          </span>

          {{#each this.operations.entries key='id' as |activity|}}
            <ActivityItem
              @compact={{true}}
              @permissions={{@permissions}}
              @showTranslationLink={{true}}
              @componentTranslationPrefix='project_activities_list_item'
              @project={{@project}}
              @activity={{activity}}
            />
          {{/each}}
          {{#if this.operations.meta.nextPage}}
            <div class='details-associations-pagination'>
              <ResourcePagination
                @meta={{this.operations.meta}}
                @onSelectPage={{fn this.refreshActivities}}
              />
            </div>
          {{/if}}
        {{/if}}
      </div>
    </div>
  </template>
  @service('intl')
  declare intl: IntlService;

  @service('apollo')
  declare apollo: Apollo;

  @not('args.project.isFileOperationsLocked')
  canRollback: boolean;

  @readOnly('args.activity.stats')
  showStats: boolean;

  @readOnly('args.activity.isRollbacked')
  isRollbacked: boolean;

  @equal('args.activity.valueType', 'EMPTY')
  isEmptyType: boolean;

  @equal('args.activity.previousTranslation.valueType', 'EMPTY')
  previousTranslationIsEmptyType: boolean;

  @tracked
  isRollbacking = false;

  @tracked
  operationsLoading = false;

  @tracked
  operations: any = [];

  @tracked
  selectedActions: string[] = [];

  translationKey = parsedKeyProperty(this.args.activity.translation?.key);

  get hasSelectedActions() {
    return this.selectedActions.length > 0;
  }

  get gitBranch() {
    const options = this.args.activity.options;
    if (!options) return;

    const option = options.find((value: string) =>
      value.startsWith('git_branch:')
    );
    if (!option) return;

    return option.slice('git_branch:'.length);
  }

  get localizedStats() {
    return this.args.activity.stats.map((stat: any) => {
      const text = this.intl.t(
        `components.project_activity.stats_text.${underscore(stat.action)}`
      );
      const count = stat.count;

      return {text, count, action: stat.action};
    });
  }

  get statsLabel() {
    return this.intl.t('components.project_activity.stats_label_text');
  }

  get actionExplanation() {
    if (!this.args.activity.action) return;

    return this.intl.t(
      `components.project_activity.action_explanation.${this.args.activity.action}`
    );
  }

  get actionText() {
    if (!this.args.activity.action) return;

    return this.intl.t(
      `components.project_activity.action_text.${this.args.activity.action}`,
      {document: this.args.activity.document?.path}
    );
  }

  get showTextDifferences() {
    return (
      this.args.activity.previousTranslation &&
      this.args.activity.previousTranslation.text &&
      this.args.activity.text !== this.args.activity.previousTranslation.text &&
      this.args.activity.text !== null
    );
  }

  get showPreviousTranslationText() {
    return (
      this.args.activity.previousTranslation.text ||
      this.args.activity.previousTranslation.valueType === 'EMPTY'
    );
  }

  get showLastSyncedText() {
    return (
      this.args.activity.previousTranslation.proposedText !==
      this.args.activity.previousTranslation.text
    );
  }

  get isRollbackable() {
    if (!this.args.onRollback) return false;
    if (!this.canRollback) return false;
    if (this.isRollbacked) return false;

    return ROLLBACKABLE_ACTIONS.indexOf(this.args.activity.action) !== -1;
  }

  @action
  async maybeFetchActivities() {
    if (
      this.args.activity.isBatch &&
      this.args.activity.action !== 'rollback'
    ) {
      await this.fetchActivities(1);
    }
  }

  @action
  async refreshActivities(page: number) {
    await this.fetchActivities(page);
  }

  @action
  async toggleAction(actionName: string) {
    if (this.selectedActions.includes(actionName)) {
      this.selectedActions = this.selectedActions.filter(
        (a) => a !== actionName
      );
    } else {
      this.selectedActions = [...this.selectedActions, actionName];
    }

    await this.fetchActivities(1);
  }

  @action
  async rollback() {
    const confirmMessage = this.intl.t(
      'components.project_activity.rollback_confirm'
    );
    /* eslint-disable-next-line no-alert */
    if (!window.confirm(confirmMessage)) {
      return;
    }

    this.isRollbacking = true;

    await this.args.onRollback();

    this.isRollbacking = false;
  }

  private async fetchActivities(page: number) {
    this.operationsLoading = true;

    const variables: Record<string, unknown> = {
      projectId: this.args.project.id,
      activityId: this.args.activity.id,
      page
    };

    if (this.selectedActions.length > 0) {
      variables.actions = this.selectedActions;
    }

    const {data} = await this.apollo.client.query<ActivityActivitiesData>({
      query: activityActivitiesQuery,
      fetchPolicy: 'network-only',
      variables
    });

    const operations = data?.viewer.project.activity.operations || [];

    this.operationsLoading = false;
    this.operations = operations;
  }
}
