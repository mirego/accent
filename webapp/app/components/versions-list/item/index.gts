import {action} from '@ember/object';
import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import {get, array, fn} from '@ember/helper';
import {LinkTo} from '@ember/routing';
import eq from 'ember-truth-helpers/helpers/eq';
import TimeAgoInWordsTag from 'accent-webapp/components/time-ago-in-words-tag/index';
import ExportSvg from 'accent-webapp/svgs/assets/export.svg';
import PencilSvg from 'accent-webapp/svgs/assets/pencil.svg';
import XSvg from 'accent-webapp/svgs/assets/x.svg';
import IntegrationLogo from 'accent-webapp/components/integration-logo/index';
import {scopedClass} from 'ember-scoped-css';
import t from 'ember-intl/helpers/t';
import AsyncButton from 'accent-webapp/components/async-button/index';

interface Args {
  permissions: Record<string, true>;
  version: any;
  project: any;
  onDelete: (versionEntity: any) => Promise<void>;
}

export default class VersionsListItem extends Component<Args> {
  <template>
    <li class='item'>
      <div class='item-info'>
        <h2 class='item-title'>
          {{#if (get @permissions 'updateVersion')}}
            <LinkTo
              @route='logged-in.project.versions.edit'
              @models={{array @project.id @version.id}}
              class='item-title-link'
            >
              {{@version.name}}
            </LinkTo>
          {{else}}
            {{@version.name}}
          {{/if}}

          {{#unless (eq @version.name @version.tag)}}
            <span class='item-tag'>
              {{@version.tag}}
            </span>
          {{/unless}}
        </h2>
        <div class='item-meta'>
          {{@version.user.fullname}}
          <span class='item-meta-date'>
            <TimeAgoInWordsTag @date={{@version.insertedAt}} />
          </span>

          {{#each @version.lastIntegrationExecutions as |execution|}}
            <LinkTo
              @route='logged-in.project.integration-executions'
              @models={{array @project.id execution.integration.id}}
              class='item-lastExecution'
            >
              <IntegrationLogo
                @service={{execution.integration.service}}
                class={{scopedClass 'item-lastExecution-logo'}}
              />
              {{t 'components.translations_list.last_execution_label'}}
              <TimeAgoInWordsTag @date={{execution.insertedAt}} />
            </LinkTo>
          {{/each}}
        </div>
      </div>

      <div class='links'>
        {{#if (get @permissions 'updateVersion')}}
          <LinkTo
            @route='logged-in.project.versions.edit'
            @models={{array @project.id @version.id}}
            class='button button--filled button--white linksButton'
          >
            <PencilSvg class='button-icon' />
            {{t 'components.versions_list.update'}}
          </LinkTo>
        {{/if}}

        {{#if (get @permissions 'exportVersion')}}
          <LinkTo
            @route='logged-in.project.versions.export'
            @models={{array @project.id @version.id}}
            class='button button--filled button--white linksButton'
          >
            <ExportSvg class='button-icon' />
            {{t 'components.versions_list.export'}}
          </LinkTo>
        {{/if}}

        {{#if (get @permissions 'deleteVersion')}}
          <AsyncButton
            @onClick={{fn this.deleteVersion @version}}
            @loading={{this.isDeleting}}
            class='button button--outline button--borderless button--red linksButton'
          >
            <XSvg class='button-icon' />
            {{t 'components.versions_list.delete'}}
          </AsyncButton>
        {{/if}}
      </div>
    </li>

    <style scoped>
      @charset "UTF-8";
      .item {
        position: relative;
        align-items: center;
        display: flex;
        margin-left: -10px;
        padding: 8px 12px;
        width: calc(100% + 10px);
        border-radius: var(--border-radius);
        transition: background 0.3s ease-in-out;
      }
      .item:focus,
      .item:hover {
        background: var(--body-background);
      }
      .item:focus .links,
      .item:hover .links {
        opacity: 1;
      }
      .item:focus .deleteButton,
      .item:hover .deleteButton {
        opacity: 1;
      }

      .item-info {
        width: 100%;
      }

      .item-title {
        display: flex;
        align-items: center;
        font-size: 18px;
        color: var(--color-primary);
      }

      .item-title-link {
        text-decoration: none;
        color: var(--color-primary);
      }
      .item-title-link:hover {
        text-decoration: underline;
      }

      .deleteButton {
        margin-left: 10px;
        opacity: 0;
        transition: opacity 0.3s ease-in-out;
      }

      .item-tag {
        display: inline-flex;
        align-items: center;
        margin-left: 10px;
        font-size: 11px;
        font-family: var(--font-monospace);
        color: var(--text-color-normal);
        text-decoration: none;
        background: var(--background-tooltip);
        padding: 1px 5px;
        border-radius: var(--border-radius);
      }

      .item-meta {
        font-size: 12px;
        display: flex;
        align-items: center;
        gap: 7px;
        color: var(--color-grey);
      }

      .item-meta-date {
        color: var(--color-grey);
      }
      .item-meta-date::before {
        content: '– ';
        opacity: 0.5;
      }

      .item-lastExecution {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        margin-left: 5px;
        color: var(--color-grey);
        font-size: 12px;
        text-decoration: none;
      }
      .item-lastExecution:hover {
        color: var(--color-black);
      }

      .item-lastExecution-logo {
        width: 14px;
        height: 14px;
      }

      .links {
        display: inline-flex;
        align-items: center;
        flex-shrink: 0;
        opacity: 0;
        gap: 4px;
        transition: opacity 0.2s ease-in-out;
      }
      .links .linksButton {
        margin-right: 6px;
      }

      @media (max-width: 800px) {
        .item {
          flex-direction: column;
          gap: 10px;
        }
        .links {
          opacity: 1;
        }
        .deleteButton {
          opacity: 1;
        }
      }
    </style>
  </template>
  @tracked
  isDeleting = false;

  @action
  async deleteVersion(version: any) {
    this.isDeleting = true;

    await this.args.onDelete(version);

    this.isDeleting = false;
  }
}
