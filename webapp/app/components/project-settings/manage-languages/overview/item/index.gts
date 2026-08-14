import {action} from '@ember/object';
import {service} from '@ember/service';
import Component from '@glimmer/component';
import IntlService from 'ember-intl/services/intl';
import {tracked} from '@glimmer/tracking';
import {LinkTo} from '@ember/routing';
import {array, get, fn} from '@ember/helper';
import AccBadge from 'accent-webapp/components/acc-badge/index';
import t from 'ember-intl/helpers/t';
import TimeAgoInWordsTag from 'accent-webapp/components/time-ago-in-words-tag/index';
import AsyncButton from 'accent-webapp/components/async-button/index';
import ChevronTopSvg from 'accent-webapp/svgs/assets/chevron-top.svg';
import PencilSvg from 'accent-webapp/svgs/assets/pencil.svg';
import XSvg from 'accent-webapp/svgs/assets/x.svg';

interface Args {
  master: any;
  permissions: Record<string, true>;
  onPromoteMaster: (revision: any) => Promise<void>;
  onDelete: (revision: any) => Promise<void>;
  project: any;
  revision: any;
}

export default class OverviewItem extends Component<Args> {
  <template>
    <div
      class='list-item
        {{if @master "list-item--master"}}
        {{if this.isPromoting "list-item--promoting"}}
        {{if this.isDeleting "list-item--deleting"}}
        {{if this.isDeleted "list-item--deleted"}}'
    >
      <div class='list-item-header'>
        {{#if this.isDeleted}}
          <span class='list-link'>{{this.name}}</span>
        {{else}}
          <LinkTo
            @route='logged-in.project.revision.translations'
            @models={{array @project.id @revision.id}}
            class='list-link'
          >
            {{this.name}}
            <small class='list-link-small'>
              {{this.slug}}
            </small>
          </LinkTo>
        {{/if}}

        {{#if @revision.isMaster}}
          <AccBadge class='masterBadge'>
            {{t 'components.project_manage_languages_overview.master_badge'}}
          </AccBadge>
        {{/if}}
      </div>

      <div class='list-item-infos'>
        {{#unless @revision.isMaster}}
          <div class='list-item-infos-date'>
            {{#if this.isDeleted}}
              {{t
                'components.project_manage_languages_overview.revision_deleted_label'
              }}
            {{else}}
              {{t
                'components.project_manage_languages_overview.revision_inserted_at_label'
              }}
              <TimeAgoInWordsTag @date={{@revision.insertedAt}} />
            {{/if}}
          </div>

          {{#unless this.isDeleted}}
            <div class='list-item-actions'>
              {{#if (get @permissions 'promoteSlave')}}
                <AsyncButton
                  @loading={{this.isPromoting}}
                  class='button--white button--filled button--small button--link promoteSlaveButton'
                  @onClick={{fn this.promoteRevision}}
                >
                  <ChevronTopSvg class='button-icon' />
                  {{t
                    'components.project_manage_languages_overview.promote_revision_master_button'
                  }}
                </AsyncButton>
              {{/if}}

              {{#unless this.isDeleted}}
                <LinkTo
                  @route='logged-in.project.manage-languages.edit'
                  @models={{array @project.id @revision.id}}
                  class='button button--filled button--white button--link button--iconOnly button--small'
                >
                  <PencilSvg class='button-icon' />
                </LinkTo>
              {{/unless}}

              {{#if (get @permissions 'deleteSlave')}}
                <AsyncButton
                  @loading={{this.isDeleting}}
                  class='button--red button--borderless button--iconOnly button--small'
                  @onClick={{fn this.deleteRevision}}
                >
                  <XSvg class='button-icon' />
                </AsyncButton>
              {{/if}}
            </div>
          {{/unless}}
        {{/unless}}
      </div>
    </div>

    <style scoped>
      .list-item {
        padding: 8px 10px;
        border-radius: var(--border-radius);
        font-size: 14px;
        transition: 0.2s ease-in-out;
        transition-property: background;
      }
      .list-item:focus,
      .list-item:hover {
        background: var(--background-light);
      }
      .list-item.list-item--deleted {
        opacity: 0.6;
        pointer-events: none;
      }
      .list-item.list-item--deleted .list-item-infos-date {
        font-size: 11px;
      }
      .list-item.list-item--deleting .list-item-actions {
        pointer-events: all;
        opacity: 1;
      }
      .list-item.list-item--master {
        margin-bottom: 6px;
        font-size: 18px;
        font-weight: bold;
      }
      .list-item:focus .list-item-actions,
      .list-item:hover .list-item-actions {
        pointer-events: all;
        opacity: 1;
      }
      .list-item:focus .list-item-header-edit,
      .list-item:hover .list-item-header-edit {
        opacity: 1;
        transform: translateX(-26px);
      }

      .list-item-header {
        position: relative;
      }

      .list-item-header-edit {
        position: absolute;
        left: 0;
        top: 3px;
        padding-right: 12px;
        color: var(--color-grey);
        opacity: 0.8;
        transform: translateX(-24px);
        transition: 0.2s ease-in-out;
        transition-property: opacity, transform, color;
      }
      .list-item-header-edit:focus,
      .list-item-header-edit:hover {
        color: var(--color-primary);
      }
      .list-item-header-edit :global(svg) {
        width: 14px;
      }

      .list-item-infos {
        display: flex;
        justify-content: space-between;
        align-items: center;
      }

      .list-item-infos-date {
        font-size: 12px;
        color: var(--color-grey);
      }

      .list-link {
        display: inline-flex;
        align-items: baseline;
        text-decoration: none;
        color: var(--color-primary);
      }
      .list-link:focus,
      .list-link:hover {
        text-decoration: underline;
      }

      .list-link-small {
        margin-left: 5px;
        font-size: 11px;
        opacity: 0.8;
      }

      .list-item-actions {
        display: flex;
        opacity: 0.8;
        pointer-events: none;
        transition: 0.2s ease-in-out;
        transition-property: opacity;
      }

      .masterBadge {
        margin-left: 10px;
      }

      .promoteSlaveButton {
        padding: 2px 6px !important;
        margin-right: 10px !important;
      }
    </style>
  </template>
  @service('intl')
  declare intl: IntlService;

  @tracked
  isPromoting = false;

  @tracked
  isDeleting = false;

  @tracked
  isDeleted = this.args.revision.markedAsDeleted;

  get name() {
    return this.args.revision.name || this.args.revision.language.name;
  }

  get slug() {
    return this.args.revision.slug || this.args.revision.language.slug;
  }

  @action
  async promoteRevision() {
    const message = this.intl.t(
      'components.project_manage_languages_overview.promote_revision_master_confirm'
    );

    // eslint-disable-next-line no-alert
    if (!window.confirm(message)) {
      return;
    }

    this.isPromoting = true;

    await this.args.onPromoteMaster(this.args.revision);

    this.isPromoting = false;
  }

  @action
  async deleteRevision() {
    const message = this.intl.t(
      'components.project_manage_languages_overview.delete_revision_confirm'
    );

    // eslint-disable-next-line no-alert
    if (!window.confirm(message)) {
      return;
    }

    this.isDeleting = true;

    await this.args.onDelete(this.args.revision);

    this.isDeleting = false;
    this.isDeleted = true;
  }
}
