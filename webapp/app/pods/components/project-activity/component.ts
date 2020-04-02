import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import {not, readOnly, equal} from '@ember/object/computed';
import Component from '@glimmer/component';
import {underscore} from '@ember/string';

import activityActivitiesQuery from 'accent-webapp/queries/activity-activities';
import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';
import IntlService from 'ember-intl/services/intl';
import Apollo from 'accent-webapp/services/apollo';
import {tracked} from '@glimmer/tracking';

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
  'merge_on_corrected',
];

interface Args {
  permissions: Record<string, true>;
  showTranslationLink: boolean;
  componentTranslationPrefix: string;
  project: any;
  activity: any;
  onRollback: () => Promise<void>;
}

export default class ProjectActivity extends Component<Args> {
  @service('intl')
  intl: IntlService;

  @service('apollo')
  apollo: Apollo;

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
  operations = [];

  translationKey = parsedKeyProperty(this.args.activity.translation?.key);

  get localizedStats() {
    return this.args.activity.stats.map((stat: any) => {
      const text = this.intl.t(
        `components.project_activity.stats_text.${underscore(stat.action)}`
      );
      const count = stat.count;

      return {text, count};
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
      `components.project_activity.action_text.${this.args.activity.action}`
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

    const variables = {
      projectId: this.args.project.id,
      activityId: this.args.activity.id,
      page,
    };

    const {data} = await this.apollo.client.query({
      query: activityActivitiesQuery,
      variables,
    });

    const operations = data.viewer.project.activity.operations;

    this.operationsLoading = false;
    this.operations = operations;
  }
}
