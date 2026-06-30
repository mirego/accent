import {service} from '@ember/service';
import {readOnly, equal} from '@ember/object/computed';
import Component from '@glimmer/component';
import {underscore, dasherize} from '@ember/string';
import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';
import IntlService from 'ember-intl/services/intl';

/* eslint camelcase:0 */
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import {scopedClass} from 'ember-scoped-css';
import t from 'ember-intl/helpers/t';
import TimeAgoInWordsTag from 'accent-webapp/components/time-ago-in-words-tag/index';
import AccAvatarImg from 'accent-webapp/components/acc-avatar-img/index';
import {LinkTo} from '@ember/routing';
import {array} from '@ember/helper';
import AccBadge from 'accent-webapp/components/acc-badge/index';
import truncate from 'accent-webapp/helpers/truncate';
import Stats from 'accent-webapp/components/activity-item/stats/index';
const ACTIONS_ICON_PATHS = {
  version_new: 'assets/tag.svg',
  fix_lint: 'assets/check-circle.svg',
  add_to_version: 'assets/tag.svg',
  create_version: 'assets/tag.svg',
  batch_sync: 'assets/sync.svg',
  batch_update: 'assets/pencil.svg',
  sync: 'assets/sync.svg',
  merge: 'assets/merge.svg',
  batch_merge: 'assets/merge.svg',
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
  document_delete: 'assets/file.svg'
};

const MAXIMUM_COMPACT_BATCH_OPERATION_DOCUMENT_PATHS = 6;

interface Args {
  compact: boolean;
  permissions: Record<string, true>;
  showTranslationLink: boolean;
  componentTranslationPrefix: string;
  activity: any;
  project: any;
}

export default class ActivityItem extends Component<Args> {
  <template>
    <div
      class='item {{if @compact "compact"}} {{if this.rollbacked "rollbacked"}}'
      data-action={{this.activityItemClassName}}
    >
      <li class='item-wrapper'>
        <span class='item-iconContainer'>
          {{inlineSvg
            this.iconPath
            class=(scopedClass 'item-iconContainer-icon')
          }}
        </span>

        <div class='item-content'>
          {{#if @activity.isRollbacked}}
            <div class='item-content-rollbacked'>
              {{t 'components.activity_item.rollbacked'}}
              <span class='item-rollbacked-date'>
                <TimeAgoInWordsTag @date={{@activity.updatedAt}} />
              </span>
            </div>
          {{/if}}

          <div class='item-header'>
            <div class='item-header-content'>
              {{#if @activity.user.isBot}}
                <span class='item-user'>
                  {{@activity.user.fullname}}
                </span>
              {{else}}
                <span
                  class='item-user
                    {{if @activity.user.pictureUrl "item-user--pictureUrl"}}'
                >
                  {{#if @activity.user.pictureUrl}}
                    <AccAvatarImg
                      src='{{@activity.user.pictureUrl}}'
                      class='item-user-picture'
                    />
                  {{/if}}
                  {{@activity.user.fullname}}
                </span>
              {{/if}}

              {{this.actionText}}

              {{#if this.showDocumentLink}}
                <LinkTo
                  @route='logged-in.project.files.export'
                  @models={{array @project.id @activity.document.id}}
                  class='item-documentPath'
                >
                  {{@activity.document.path}}
                </LinkTo>
              {{else if this.showDocumentInfo}}
                <span class='item-documentPath'>
                  {{@activity.document.path}}
                </span>
              {{/if}}

              {{#if this.showVersionInfo}}
                <AccBadge
                  @link={{true}}
                  @version={{true}}
                  class='item-version-tag'
                >
                  <LinkTo
                    @route='logged-in.project.versions.export'
                    @models={{array @project.id @activity.version.id}}
                  >
                    {{@activity.version.tag}}
                  </LinkTo>
                </AccBadge>
              {{/if}}

              {{#if this.showRevisionInfo}}
                <LinkTo
                  @route='logged-in.project.revision.translations'
                  @models={{array @project.id @activity.revision.id}}
                  class='item-revisionLink'
                >
                  {{this.revisionName}}
                </LinkTo>
              {{/if}}

              {{#if this.showBatchedOperations}}
                {{#if @compact}}
                  {{#if this.compactedBatchedOperations}}
                    {{#each this.compactBatchedOperations as |activity|}}
                      <span
                        class='item-batchedOperations-path'
                      >{{activity.document.path}}</span>
                    {{/each}}

                    <span class='item-batchedOperations-hiddenCount'>
                      {{t
                        'components.activity_item.batch_operations_hidden_count'
                        count=this.compactBatchedOperationsHiddenCount
                      }}
                    </span>
                  {{else}}
                    {{#each @activity.batchedOperations as |activity|}}
                      <span
                        class='item-batchedOperations-path'
                      >{{activity.document.path}}</span>
                    {{/each}}
                  {{/if}}
                {{/if}}
              {{/if}}

              {{#if this.isShowingTranslationLink}}
                {{#if @activity.translation.isRemoved}}
                  <LinkTo
                    @route='logged-in.project.translation'
                    @models={{array @project.id @activity.translation.id}}
                    class='item-translationLink item-translationLink--removed'
                  >
                    <small class='item-translationLink-prefix'>
                      {{#if this.translationKey.prefix}}
                        {{this.translationKey.prefix}}
                      {{else}}
                        {{@activity.document.path}}
                      {{/if}}
                    </small>
                    {{this.translationKey.value}}
                  </LinkTo>
                {{else}}
                  <LinkTo
                    @route='logged-in.project.translation'
                    @models={{array @project.id @activity.translation.id}}
                    class='item-translationLink'
                  >
                    <small class='item-translationLink-prefix'>
                      {{#if this.translationKey.prefix}}
                        {{this.translationKey.prefix}}
                      {{else}}
                        {{@activity.document.path}}
                      {{/if}}
                    </small>
                    {{this.translationKey.value}}
                  </LinkTo>
                {{/if}}
              {{/if}}
            </div>

            <div class='item-actions'>
              <span class='item-date'><TimeAgoInWordsTag
                  @date={{@activity.insertedAt}}
                /></span>
              <LinkTo
                @route='logged-in.project.activity'
                @models={{array @project.id @activity.id}}
                class='item-details-link'
              >
                {{t 'components.activity_item.details'}}
              </LinkTo>
            </div>
          </div>

          {{#if @activity.rollbackedOperation}}
            <div class='item-rollback-content'>
              <div>
                <span class='item-rollback-user'>
                  {{@activity.rollbackedOperation.user.fullname}}
                </span>
                {{this.rollbackedOperationActionText}}

                {{#if this.showFromOperationTranslationLink}}
                  {{#if @activity.rollbackedOperation.translation.isRemoved}}
                    <LinkTo
                      @route='logged-in.project.translation'
                      @models={{array
                        @project.id
                        @activity.rollbackedOperation.translation.id
                      }}
                      class='item-translationLink--removed'
                    >
                      {{@activity.rollbackedOperation.translation.key}}
                    </LinkTo>
                  {{else}}
                    <LinkTo
                      @route='logged-in.project.translation'
                      @models={{array
                        @project.id
                        @activity.rollbackedOperation.translation.id
                      }}
                      class='item-translationLink'
                    >
                      {{@activity.rollbackedOperation.translation.key}}
                    </LinkTo>
                  {{/if}}
                {{/if}}

                {{#if @activity.fromOperation.text}}
                  <div class='item-translationFromOperationText'>
                    {{@activity.fromOperation.text}}
                  </div>
                {{else if this.fromOperationHasEmptyText}}
                  <div class='item-translationFromOperationText'>
                    <span class='item-translationText-emptyText'>
                      {{t 'components.activity_item.empty_text'}}
                    </span>
                  </div>
                {{/if}}

                {{#if this.showFromOperationDocumentInfo}}
                  <LinkTo
                    @route='logged-in.project.files.export'
                    @models={{array
                      @project.id
                      @activity.rollbackedOperation.document.id
                    }}
                    class='item-documentPath'
                  >
                    {{@activity.rollbackedOperation.document.path}}
                  </LinkTo>
                {{/if}}
              </div>

              {{#unless @compact}}
                <span class='item-date'>
                  <TimeAgoInWordsTag
                    @date={{@activity.rollbackedOperation.insertedAt}}
                  />
                </span>
                <LinkTo
                  @route='logged-in.project.activity'
                  @models={{array @project.id @activity.rollbackedOperation.id}}
                  class='item-details-link'
                >
                  {{t 'components.activity_item.details'}}
                </LinkTo>
              {{/unless}}
            </div>
          {{/if}}

          {{#if @activity.text}}
            <div class='item-translationText'>
              <div class='item-translationText-text'>{{truncate
                  @activity.text
                  160
                }}</div>
            </div>
          {{else if this.hasEmptyText}}
            <div class='item-translationText'>
              <span class='item-translationText-emptyText'>
                {{t 'components.activity_item.empty_text'}}
              </span>
            </div>
          {{/if}}

          {{#if this.showStats}}
            <div class='item-stats'>
              <span class='item-stats-label'>
                {{this.statsLabel}}
              </span>

              <Stats
                @stats={{@activity.stats}}
                @componentTranslationPrefix={{@componentTranslationPrefix}}
              />
            </div>
          {{/if}}

          {{#if this.showBatchedOperations}}
            {{#unless @compact}}
              <ul class='item-batchedOperations'>
                {{#each @activity.batchedOperations as |activity|}}
                  <li class='item-batchedOperations-item'>
                    <LinkTo
                      @route='logged-in.project.files.export'
                      @models={{array @project.id activity.document.id}}
                      class='item-batchedOperations-label'
                    >
                      {{activity.document.path}}
                    </LinkTo>

                    <Stats
                      @stats={{activity.stats}}
                      @componentTranslationPrefix={{@componentTranslationPrefix}}
                    />
                  </li>
                {{/each}}
              </ul>
            {{/unless}}
          {{/if}}
        </div>
      </li>
    </div>
  </template>
  @service('intl')
  declare intl: IntlService;

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

  get showBatchedOperations() {
    return this.args.activity.batchedOperations?.length;
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

  get showDocumentLink() {
    return this.showDocumentInfo && this.action !== 'document_delete';
  }

  get compactedBatchedOperations() {
    return (
      this.args.activity.batchedOperations.length >
      MAXIMUM_COMPACT_BATCH_OPERATION_DOCUMENT_PATHS
    );
  }

  get compactBatchedOperations() {
    return this.args.activity.batchedOperations.slice(
      0,
      MAXIMUM_COMPACT_BATCH_OPERATION_DOCUMENT_PATHS
    );
  }

  get compactBatchedOperationsHiddenCount() {
    return (
      this.args.activity.batchedOperations.length -
      MAXIMUM_COMPACT_BATCH_OPERATION_DOCUMENT_PATHS
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
      'conflict_on_slave'
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
