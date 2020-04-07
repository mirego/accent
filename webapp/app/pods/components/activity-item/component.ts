import {inject as service} from '@ember/service';
import {readOnly, equal} from '@ember/object/computed';
import Component from '@glimmer/component';
import {underscore, dasherize} from '@ember/string';

import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';
import IntlService from 'ember-intl/services/intl';

/* eslint camelcase:0 */
const ACTIONS_ICON_PATHS = {
  version_new: 'assets/tag.svg',
  add_to_version: 'assets/tag.svg',
  create_version: 'assets/tag.svg',
  sync: 'assets/sync.svg',
  merge: 'assets/merge.svg',
  rollback: 'assets/revert.svg',
  update: 'assets/pencil.svg',
  correct_conflict: 'assets/check.svg',
  correct_all: 'assets/check.svg',
  uncorrect_all: 'assets/revert.svg',
  uncorrect_conflict: 'assets/revert.svg',
  conflict_on_slave: 'assets/x.svg',
  conflict_on_corrected: 'assets/x.svg',
  conflict_on_proposed: 'assets/x.svg',
  remove: 'assets/x.svg',
  new_comment: 'assets/bubble.svg',
  new_slave: 'assets/language.svg',
  document_delete: 'assets/file.svg',
};

interface Args {
  compact: boolean;
  permissions: Record<string, true>;
  showTranslationLink: boolean;
  componentTranslationPrefix: string;
  activity: any;
  project: any;
}

export default class ActivityItem extends Component<Args> {
  @service('intl')
  intl: IntlService;

  @readOnly('args.activity.action')
  action: keyof typeof ACTIONS_ICON_PATHS;

  @readOnly('args.activity.isRollbacked')
  rollbacked: boolean;

  @equal('args.activity.rollbackedOperation.valueType', 'EMPTY')
  rollbackedOperationHasEmptyText: boolean;

  @equal('args.activity.fromOperation.text', 'EMPTY')
  fromOperationHasEmptyText: boolean;

  @equal('args.activity.valueType', 'EMPTY')
  hasEmptyText: boolean;

  @readOnly('args.activity.version.id')
  showVersionInfo: boolean;

  translationKey = parsedKeyProperty(this.args.activity.translation?.key);

  get activityItemClassName() {
    return dasherize(this.args.activity.action);
  }

  get actionText() {
    return this.getActionText(this.action);
  }

  get rollbackedOperationActionText() {
    return this.getActionText(this.args.activity.rollbackedOperation.action);
  }

  get showFromOperationTranslationLink() {
    return (
      this.args.showTranslationLink &&
      this.args.activity.rollbackedOperation &&
      this.args.activity.rollbackedOperation.translation &&
      this.args.activity.rollbackedOperation.translation.id
    );
  }

  get showStats() {
    return this.args.activity.stats;
  }

  get localizedStats() {
    return this.args.activity.stats.map((stat: any) => {
      const text = this.intl.t(
        `components.${
          this.args.componentTranslationPrefix
        }.stats_text.${underscore(stat.action)}`
      );

      const count = stat.count;

      return {text, count};
    });
  }

  get statsLabel() {
    return this.intl.t(
      `components.${this.args.componentTranslationPrefix}.stats_label_text`
    );
  }

  get showDocumentInfo() {
    const action = this.action;
    const actionsWithDocument = ['sync', 'document_delete', 'merge'];

    return (
      actionsWithDocument.includes(action) &&
      this.args.activity.document &&
      this.args.activity.document.path
    );
  }

  get revisionName() {
    return (
      this.args.activity.revision.name ||
      this.args.activity.revision.language.name
    );
  }

  get showRevisionInfo() {
    if (!this.args.activity.revision) return false;

    const actionsWithRevision = [
      'new',
      'remove',
      'renew',
      'new_slave',
      'merge',
      'uncorrect_all',
      'correct_all',
      'batch_correct_conflict',
      'batch_update',
      'conflict_on_slave',
    ];

    return (
      actionsWithRevision.includes(this.action) &&
      this.args.activity.revision.language.id
    );
  }

  get showFromOperationDocumentInfo() {
    const action = this.args.activity.rollbackedOperation.action;
    const actionsWithDocument = ['sync', 'document_delete', 'merge'];

    return (
      actionsWithDocument.includes(action) &&
      this.args.activity.rollbackedOperation.document.path
    );
  }

  get isShowingTranslationLink() {
    return (
      this.args.showTranslationLink &&
      this.args.activity.translation &&
      this.args.activity.action !== 'rollback'
    );
  }

  get iconPath() {
    return ACTIONS_ICON_PATHS[this.action] || 'assets/add.svg';
  }

  private getActionText(action: keyof typeof ACTIONS_ICON_PATHS) {
    return this.intl.t(
      `components.${this.args.componentTranslationPrefix}.action_text.${action}`
    );
  }
}
