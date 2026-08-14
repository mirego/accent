import {service} from '@ember/service';
import {readOnly, equal} from '@ember/object/computed';
import Component from '@glimmer/component';
import {underscore, dasherize} from '@ember/string';
import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';
import IntlService from 'ember-intl/services/intl';

/* eslint camelcase:0 */
import {scopedClass} from 'ember-scoped-css';
import t from 'ember-intl/helpers/t';
import TimeAgoInWordsTag from 'accent-webapp/components/time-ago-in-words-tag/index';
import AccAvatarImg from 'accent-webapp/components/acc-avatar-img/index';
import {LinkTo} from '@ember/routing';
import {array} from '@ember/helper';
import AccBadge from 'accent-webapp/components/acc-badge/index';
import truncate from 'accent-webapp/helpers/truncate';
import Stats from 'accent-webapp/components/activity-item/stats/index';
import AddSvg from 'accent-webapp/svgs/assets/add.svg';
import BubbleSvg from 'accent-webapp/svgs/assets/bubble.svg';
import CheckSvg from 'accent-webapp/svgs/assets/check.svg';
import CheckCircleSvg from 'accent-webapp/svgs/assets/check-circle.svg';
import FileSvg from 'accent-webapp/svgs/assets/file.svg';
import LanguageSvg from 'accent-webapp/svgs/assets/language.svg';
import MergeSvg from 'accent-webapp/svgs/assets/merge.svg';
import PencilSvg from 'accent-webapp/svgs/assets/pencil.svg';
import RevertSvg from 'accent-webapp/svgs/assets/revert.svg';
import SyncSvg from 'accent-webapp/svgs/assets/sync.svg';
import TagSvg from 'accent-webapp/svgs/assets/tag.svg';
import XSvg from 'accent-webapp/svgs/assets/x.svg';

const ACTIONS_ICON_COMPONENTS = {
  version_new: TagSvg,
  fix_lint: CheckCircleSvg,
  add_to_version: TagSvg,
  create_version: TagSvg,
  batch_sync: SyncSvg,
  batch_update: PencilSvg,
  sync: SyncSvg,
  merge: MergeSvg,
  batch_merge: MergeSvg,
  rollback: RevertSvg,
  update: PencilSvg,
  correct_conflict: CheckSvg,
  correct_all: CheckSvg,
  uncorrect_all: RevertSvg,
  uncorrect_conflict: RevertSvg,
  conflict_on_slave: XSvg,
  conflict_on_corrected: XSvg,
  conflict_on_proposed: XSvg,
  remove: XSvg,
  new_comment: BubbleSvg,
  new_slave: LanguageSvg,
  document_delete: FileSvg
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
          <this.iconComponent class={{scopedClass 'item-iconContainer-icon'}} />
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

    <style scoped>
      .item {
        display: flex;
        position: relative;
        margin: 25px 0;
        border-radius: 0 3px 3px 0;
        z-index: 10;
      }
      .item .item-iconContainer {
        left: -1px;
      }

      .item[data-action='rollback'],
      .item[data-action='batch-merge'],
      .item[data-action='merge'],
      .item[data-action='new-slave'],
      .item[data-action='uncorrect-all'],
      .item[data-action='correct-all'],
      .item[data-action='batch-sync'],
      .item[data-action='sync'] {
        left: 10px;
        width: calc(100% - 9px);
        padding: 5px;
        background: var(--content-background);
        border: 1px solid var(--background-light-highlight);
        border-left: 0;
      }
      .item[data-action='rollback'] .item-iconContainer,
      .item[data-action='batch-merge'] .item-iconContainer,
      .item[data-action='merge'] .item-iconContainer,
      .item[data-action='new-slave'] .item-iconContainer,
      .item[data-action='uncorrect-all'] .item-iconContainer,
      .item[data-action='correct-all'] .item-iconContainer,
      .item[data-action='batch-sync'] .item-iconContainer,
      .item[data-action='sync'] .item-iconContainer {
        top: 3px;
        left: -16px;
      }
      .item[data-action='rollback'] .item-content,
      .item[data-action='batch-merge'] .item-content,
      .item[data-action='merge'] .item-content,
      .item[data-action='new-slave'] .item-content,
      .item[data-action='uncorrect-all'] .item-content,
      .item[data-action='correct-all'] .item-content,
      .item[data-action='batch-sync'] .item-content,
      .item[data-action='sync'] .item-content {
        width: 100%;
        padding: 5px 5px 0 2px;
        margin-left: -16px;
        background: var(--content-background);
        border-bottom: 0;
      }

      .item[data-action='batch-sync'],
      .item[data-action='sync'] {
        position: relative;
        transform: translateX(-1px);
        padding: 6px 10px 5px;
        border-color: transparent;
        border-left: 1px solid
          color-mix(in srgb, var(--color-primary) 90%, black);
      }
      .item[data-action='batch-sync'].compact,
      .item[data-action='sync'].compact {
        border-left: 1px solid
          color-mix(in srgb, var(--color-primary) 90%, black);
      }
      .item[data-action='batch-sync']:before,
      .item[data-action='sync']:before {
        display: block;
        position: absolute;
        top: 0;
        left: 0;
        content: '';
        width: 100%;
        height: 100%;
        background: var(--color-primary);
        opacity: 0.16;
        pointer-events: none;
      }
      .item[data-action='batch-sync'] .item-iconContainer,
      .item[data-action='sync'] .item-iconContainer {
        left: -21px;
        background: var(--color-primary);
        border-color: transparent;
        box-shadow: none;
      }
      .item[data-action='batch-sync'] .item-iconContainer-icon,
      .item[data-action='sync'] .item-iconContainer-icon {
        stroke: var(--content-background);
      }
      .item[data-action='batch-sync'] .item-stats,
      .item[data-action='sync'] .item-stats {
        padding: 0;
        background: transparent;
        color: var(--text-color-normal);
      }
      .item[data-action='batch-sync'] .item-date,
      .item[data-action='sync'] .item-date {
        color: color-mix(in srgb, var(--color-primary) 50%, black);
      }
      .item[data-action='batch-sync'] .item-details-link,
      .item[data-action='sync'] .item-details-link {
        color: var(--color-primary);
      }
      .item[data-action='batch-sync'] .item-content,
      .item[data-action='sync'] .item-content {
        background: var(--color-primary-lighten-95);
        color: color-mix(in srgb, var(--color-primary) 50%, black);
      }
      .item[data-action='batch-sync'] .item-documentPath,
      .item[data-action='sync'] .item-documentPath {
        color: var(--color-primary-darken-30);
      }
      .item[data-action='batch-sync'] .item-user,
      .item[data-action='batch-sync'] .item-header-content,
      .item[data-action='sync'] .item-user,
      .item[data-action='sync'] .item-header-content {
        color: var(--color-primary-darken-30);
      }
      .item[data-action='batch-sync'].compact .item-content,
      .item[data-action='sync'].compact .item-content {
        padding-left: 0;
      }
      .item[data-action='batch-sync'].compact .item-header,
      .item[data-action='sync'].compact .item-header {
        margin-bottom: 0;
      }
      .item[data-action='batch-sync'].compact .item-iconContainer-icon,
      .item[data-action='sync'].compact .item-iconContainer-icon {
        stroke: var(--color-primary);
      }
      .item[data-action='batch-sync'].compact .item-user,
      .item[data-action='batch-sync'].compact .item-header-content,
      .item[data-action='sync'].compact .item-user,
      .item[data-action='sync'].compact .item-header-content {
        font-size: 12px;
      }

      .item[data-action='rollback'] {
        background: var(--background-light);
        border: 1px solid var(--background-light-highlight);
      }
      .item[data-action='rollback'] .item-header {
        margin-bottom: 4px;
      }
      .item[data-action='rollback'] .item-iconContainer {
        display: none;
      }
      .item[data-action='rollback'] .item-translationLink {
        margin-top: 2px;
      }
      .item[data-action='rollback'] .item-content {
        padding: 5px 0 0;
        margin: 0;
        background: var(--background-light);
        border-bottom: 0;
      }

      .item[data-action='uncorrect-all'] .item-iconContainer {
        background: var(--color-error);
        border-color: transparent;
      }
      .item[data-action='uncorrect-all'] .item-iconContainer-icon {
        stroke: var(--content-background);
      }
      .item[data-action='uncorrect-all'].compact .item-iconContainer-icon {
        stroke: var(--color-error);
      }

      .item[data-action='correct-all'].compact .item-iconContainer-icon {
        stroke: var(--color-success);
      }
      .item[data-action='correct-all'] .item-iconContainer {
        background: var(--color-success);
        border-color: transparent;
      }
      .item[data-action='correct-all'] .item-iconContainer-icon {
        stroke: var(--content-background);
      }

      .item[data-action='document-delete'] .item-iconContainer {
        background: var(--color-error);
        border-color: transparent;
      }
      .item[data-action='document-delete'] .item-iconContainer-icon {
        stroke: var(--content-background);
      }
      .item[data-action='document-delete'].compact .item-iconContainer-icon {
        stroke: var(--color-error);
      }

      .item[data-action='correct-conflict'] .item-iconContainer {
        border-color: var(--color-success);
      }
      .item[data-action='correct-conflict'] .item-iconContainer-icon {
        stroke: var(--color-success);
      }

      .item[data-action='uncorrect-conflict'] .item-iconContainer {
        border-color: var(--color-error);
      }
      .item[data-action='uncorrect-conflict'] .item-iconContainer-icon {
        stroke: var(--color-error);
      }

      .item[data-action='conflict-on-corrected'] .item-iconContainer {
        border-color: var(--color-error);
      }
      .item[data-action='conflict-on-corrected'] .item-iconContainer-icon {
        stroke: var(--color-error);
      }

      .item[data-action='conflict-on-proposed'] .item-iconContainer {
        border-color: var(--color-warning);
      }
      .item[data-action='conflict-on-proposed'] .item-iconContainer-icon {
        stroke: var(--color-warning);
      }

      .item.rollbacked .item-stats,
      .item.rollbacked .item-translationText,
      .item.rollbacked .item-actions,
      .item.rollbacked .item-header {
        opacity: 0.6;
        font-size: 12px;
      }
      .item.rollbacked .item-translationText {
        padding: 0;
        background: transparent;
      }
      .item.rollbacked .item-iconContainer {
        background: var(--content-background);
        border-color: var(--content-background-border);
      }
      .item.rollbacked .item-iconContainer-icon {
        width: 11px;
        height: 11px;
        stroke: var(--content-background-border);
      }
      .item.rollbacked.rollback,
      .item.rollbacked.batch-merge,
      .item.rollbacked.merge,
      .item.rollbacked.new-slave,
      .item.rollbacked.uncorrect-all,
      .item.rollbacked.correct-all {
        border-color: var(--background-light-highlight);
      }
      .item.rollbacked.rollback .item-iconContainer,
      .item.rollbacked.batch-merge .item-iconContainer,
      .item.rollbacked.merge .item-iconContainer,
      .item.rollbacked.new-slave .item-iconContainer,
      .item.rollbacked.uncorrect-all .item-iconContainer,
      .item.rollbacked.correct-all .item-iconContainer {
        left: -19px;
        top: 6px;
      }
      .item.rollbacked.batch-sync:before,
      .item.rollbacked.sync:before {
        display: none;
      }
      .item.rollbacked.batch-sync .item-iconContainer,
      .item.rollbacked.sync .item-iconContainer {
        left: -19px;
        top: 6px;
      }

      .item[data-action='rollback'].compact .item-iconContainer {
        top: -2px;
        left: -13px;
        display: block;
      }
      .item[data-action='rollback'].compact .item-content {
        margin-left: -20px;
      }

      .item.rollbacked.compact,
      .item.compact {
        width: 100%;
        margin: 12px 0 2px;
        border-color: transparent;
        background: transparent;
        box-shadow: none;
      }
      .item.rollbacked.compact:last-of-type .item-content,
      .item.compact:last-of-type .item-content {
        border-bottom: 0;
      }
      .item.rollbacked.compact .item-stats,
      .item.compact .item-stats {
        display: none;
      }
      .item.rollbacked.compact .item-header,
      .item.compact .item-header {
        font-size: 11px;
        flex-direction: column;
        align-items: flex-start;
      }
      .item.rollbacked.compact .item-actions,
      .item.compact .item-actions {
        margin: 2px 0 0;
        text-align: left;
      }
      .item.rollbacked.compact .item-content,
      .item.compact .item-content {
        padding-top: 2px;
        background: transparent;
      }
      .item.rollbacked.compact .item-iconContainer,
      .item.compact .item-iconContainer {
        border-color: var(--content-background);
        background: var(--content-background);
      }
      .item.rollbacked.compact .item-rollback-content,
      .item.compact .item-rollback-content {
        margin: 5px 0;
        padding: 5px 10px;
        font-size: 11px;
        background: var(--background-light);
        color: #888;
      }
      .item.rollbacked.compact .item-content-rollbacked,
      .item.compact .item-content-rollbacked {
        margin-bottom: 1px;
        font-size: 11px;
      }
      .item.rollbacked.compact .item-translationText,
      .item.compact .item-translationText {
        display: none;
      }
      .item.rollbacked.compact .item-translationLink,
      .item.compact .item-translationLink {
        font-size: 11px;
        margin-left: 0;
        margin-top: 0;
      }
      .item.rollbacked.compact .item-revisionLink,
      .item.compact .item-revisionLink {
        font-size: 11px;
      }
      .item.rollbacked.compact .item-documentPath,
      .item.compact .item-documentPath {
        font-size: 11px;
      }
      .item.rollbacked.compact .item-user-picture,
      .item.compact .item-user-picture {
        width: 15px;
        height: 15px;
      }
      .item.rollbacked.compact .item-details-link,
      .item.compact .item-details-link {
        opacity: 0.7;
      }

      .item-wrapper {
        display: flex;
        width: 100%;
      }

      .item-version-tag {
        margin-left: 6px;
        font-size: 11px;
      }

      .item-iconContainer {
        display: flex;
        position: relative;
        top: 0;
        flex: 0 0 21px;
        align-items: center;
        justify-content: center;
        width: 21px;
        height: 21px;
        margin-right: 10px;
        border-radius: 50%;
        border: 1px solid var(--color-grey);
        box-shadow: 0 0 0 5px var(--content-background);
        background: var(--content-background);
      }

      .item-iconContainer-icon {
        width: 11px;
        height: 11px;
        flex: 0 0 11px;
        stroke: var(--color-grey);
      }

      .item-content {
        flex: 1 1 100%;
        font-size: 13px;
      }

      .item.compact .item-header {
        flex-direction: column;
      }
      .item.compact .item-actions {
        min-width: 0;
        text-align: left;
      }

      .item-header {
        display: flex;
        justify-content: space-between;
        margin: 0 0 10px;
      }

      .item-header-content {
        display: flex;
        flex-wrap: wrap;
        align-items: center;
        flex: 1 1 auto;
        font-size: 12px;
      }

      .item-user {
        position: relative;
        display: inline-flex;
        align-items: center;
        font-weight: bold;
        margin-right: 3px;
      }

      .item-user-picture {
        width: 17px;
        height: 17px;
        margin-right: 5px;
        border-radius: var(--border-radius);
      }

      .item-translationFromOperationText,
      .item-stats,
      .item-translationText {
        margin: 5px 0 10px;
        padding: 8px;
        background: var(--background-light);
        font-size: 12px;
        font-style: italic;
      }

      .item-translationText-text {
        white-space: pre-wrap;
      }

      .item-batchedOperations {
        display: grid;
        gap: 10px 8px;
        margin-bottom: 10px;
        grid-template-columns: 1fr 1fr 1fr 1fr 1fr;
      }

      .item-batchedOperations-path {
        margin-left: 3px;
        font-size: 11px;
        font-weight: 600;
      }
      .item-batchedOperations-path::after {
        font-weight: 300;
        content: ', ';
      }
      .item-batchedOperations-path:last-of-type::after {
        content: '';
      }

      .item-batchedOperations-item {
        padding: 8px 18px 6px 0;
        font-size: 12px;
      }
      .item-batchedOperations-item:last-of-type {
        border-color: transparent;
      }

      .item-batchedOperations-label {
        font-weight: 600;
        text-decoration: none;
      }

      .item-batchedOperations-hiddenCount {
        font-size: 11px;
        margin-left: 4px;
      }

      .item-translationFromOperationText {
        background: transparent;
        padding: 5px 0;
        margin: 10px 0 0;
      }

      .item-stats-label,
      .item-translationText-label {
        display: block;
        margin-bottom: 4px;
        font-size: 11px;
        font-weight: bold;
        font-style: normal;
      }

      .item-translationText-emptyText {
        color: #ccc;
      }

      a.item-documentPath {
        text-decoration: none;
      }
      a.item-documentPath:focus,
      a.item-documentPath:hover {
        text-decoration: underline;
      }

      .item-documentPath {
        display: inline-block;
        margin-left: 3px;
        color: var(--color-black);
        font-weight: bold;
        font-size: 12px;
      }

      .item-translationLink {
        display: block;
        flex: 1 0 auto;
        width: 100%;
        margin-top: 5px;
        text-decoration: none;
        font-size: 12px;
        font-weight: bold;
        font-family: var(--font-monospace);
        word-break: break-all;
        transition: 0.2s ease-in-out;
        transition-property: color;
        color: var(--color-primary);
      }
      .item-translationLink:hover,
      .item-translationLink:focus {
        color: color-mix(in srgb, var(--color-primary) 90%, black);
      }
      .item-translationLink.item-translationLink--removed {
        color: #666;
      }

      .item-translationLink-prefix {
        display: block;
        font-weight: normal;
        font-size: 11px;
        color: #959595;
      }

      .item-revisionLink {
        display: inline-block;
        margin-left: 3px;
        text-decoration: none;
        color: var(--color-primary);
      }
      .item-revisionLink:hover,
      .item-revisionLink:focus {
        text-decoration: underline;
      }

      .item-actions {
        flex: 0 1 auto;
        margin: 0;
        text-align: right;
      }

      .item-date {
        opacity: 0.4;
        color: var(--color-black);
        font-size: 11px;
      }

      .item-stats {
        list-style: none;
        border-radius: var(--border-radius);
      }

      .item-rollback {
        transition: 0.2s ease-in-out;
        transition-property: opacity, color;
        opacity: 0;
        background: none;
        padding: 0;
        margin: 0 0 0 5px;
        color: var(--color-grey);
        font-size: 11px;
      }
      .item-rollback:focus,
      .item-rollback:hover {
        color: var(--background-light-highlight);
        text-decoration: underline;
      }

      .item-rollback-content {
        width: 100%;
        padding: 10px;
        margin: 10px 0;
        background: var(--content-background);
        font-size: 12px;
        font-style: italic;
        color: #5d6863;
      }
      .item-rollback-content .item-translationLink {
        font-size: 11px;
      }
      .item-rollback-content .item-details-link {
        font-weight: bold;
      }

      .item-rollback-user {
        font-weight: bold;
      }

      .item-details-link {
        padding-left: 6px;
        margin-left: 5px;
        border-left: 1px solid var(--background-light-highlight);
        text-decoration: none;
        color: var(--color-black);
        font-size: 11px;
        font-weight: 500;
      }
      .item-details-link:focus,
      .item-details-link:hover {
        text-decoration: underline;
        color: var(--color-primary);
      }

      .item-content-rollbacked {
        margin-bottom: 6px;
        color: var(--color-error);
        font-size: 12px;
        font-weight: 500;
      }
    </style>
  </template>
  @service('intl')
  declare intl: IntlService;

  @readOnly('args.activity.action')
  action: keyof typeof ACTIONS_ICON_COMPONENTS;

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

  get iconComponent() {
    return ACTIONS_ICON_COMPONENTS[this.action] || AddSvg;
  }

  private getActionText(action: keyof typeof ACTIONS_ICON_COMPONENTS) {
    return this.intl.t(
      `components.${this.args.componentTranslationPrefix}.action_text.${action}`
    );
  }
}
