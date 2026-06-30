import {action} from '@ember/object';
import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import {get, array, fn} from '@ember/helper';
import {LinkTo} from '@ember/routing';
import eq from 'ember-truth-helpers/helpers/eq';
import TimeAgoInWordsTag from 'accent-webapp/components/time-ago-in-words-tag/index';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import integrationLogo from 'accent-webapp/helpers/integration-logo';
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
              {{inlineSvg
                (integrationLogo execution.integration.service)
                class=(scopedClass 'item-lastExecution-logo')
              }}
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
            class='button button--filled button--white'
          >
            {{inlineSvg '/assets/pencil.svg' class='button-icon'}}
            {{t 'components.versions_list.update'}}
          </LinkTo>
        {{/if}}

        {{#if (get @permissions 'exportVersion')}}
          <LinkTo
            @route='logged-in.project.versions.export'
            @models={{array @project.id @version.id}}
            class='button button--filled button--white'
          >
            {{inlineSvg '/assets/export.svg' class='button-icon'}}
            {{t 'components.versions_list.export'}}
          </LinkTo>
        {{/if}}

        {{#if (get @permissions 'deleteVersion')}}
          <AsyncButton
            @onClick={{fn this.deleteVersion @version}}
            @loading={{this.isDeleting}}
            class='button button--outline button--borderless button--red'
          >
            {{inlineSvg '/assets/x.svg' class='button-icon'}}
            {{t 'components.versions_list.delete'}}
          </AsyncButton>
        {{/if}}
      </div>
    </li>
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
