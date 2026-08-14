import {action} from '@ember/object';
import {service} from '@ember/service';
import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import IntlService from 'ember-intl/services/intl';
import Form from 'accent-webapp/components/project-settings/integrations/form/index';
import {fn, array, get} from '@ember/helper';
import HistorySvg from 'accent-webapp/svgs/assets/history.svg';
import PencilSvg from 'accent-webapp/svgs/assets/pencil.svg';
import PlaySvg from 'accent-webapp/svgs/assets/play.svg';
import XSvg from 'accent-webapp/svgs/assets/x.svg';
import IntegrationLogo from 'accent-webapp/components/integration-logo/index';
import {scopedClass} from 'ember-scoped-css';
import t from 'ember-intl/helpers/t';
import timeAgoInWords from 'accent-webapp/helpers/time-ago-in-words';
import {on} from '@ember/modifier';
import {LinkTo} from '@ember/routing';
import AsyncButton from 'accent-webapp/components/async-button/index';
import AccModal from 'accent-webapp/components/acc-modal/index';
import AzureStorageContainer from 'accent-webapp/components/project-settings/integrations/list/item/execute/azure-storage-container/index';
import AwsS3 from 'accent-webapp/components/project-settings/integrations/list/item/execute/aws-s3/index';

const EXECUTABLE_SERVICES = ['AZURE_STORAGE_CONTAINER', 'AWS_S3'];

interface Args {
  project: any;
  permissions: Record<string, true>;
  integration: any;
  onUpdate: (args: any) => Promise<{errors: any}>;
  onDelete: ({id}: {id: string}) => Promise<{errors: any}>;
}

export default class IntegrationsListItem extends Component<Args> {
  <template>
    <li class='project-settings-integrations-list-item'>
      {{#if this.isEditing}}
        <Form
          @integration={{@integration}}
          @project={{@project}}
          @errors={{this.errors}}
          @onSubmit={{fn this.update}}
          @onCancel={{fn this.toggleEdit}}
        />
      {{else}}
        <div class='details'>
          <div class='details-info'>
            <IntegrationLogo
              @service={{@integration.service}}
              class={{scopedClass 'details-logo'}}
            />
            <span class='details-service'>
              {{t this.mappedServiceTranslationKey}}
            </span>

            <span class='details-preview'>
              {{@integration.data.url}}
              {{@integration.data.sasBaseUrl}}
              {{@integration.data.accessKeyId}}
              {{@integration.data.bucket}}
              {{@integration.data.pathPrefix}}

              {{#if @integration.lastIntegrationExecution}}
                <span class='details-last-executed-at'>{{t
                    'components.project_settings.integrations.last_executed_at'
                  }}
                  {{timeAgoInWords
                    @integration.lastIntegrationExecution.insertedAt
                  }}</span>
              {{/if}}
            </span>
          </div>

          <div class='details-actions'>
            {{#if this.serviceIsExecutable}}
              <button
                class='button button--filled'
                {{on 'click' (fn this.toggleExecuting)}}
              >
                <PlaySvg class='button-icon' />
                {{t 'components.project_settings.integrations.play'}}
              </button>
            {{/if}}

            <LinkTo
              @route='logged-in.project.integration-executions'
              @models={{array @project.id @integration.id}}
              class='button button--filled button--white'
              title={{t
                'components.project_settings.integrations.executions_button'
              }}
            >
              <HistorySvg class='button-icon' />
              {{t 'components.project_settings.integrations.history'}}
            </LinkTo>

            {{#if (get @permissions 'updateProjectIntegration')}}
              <button
                class='button button--filled button--white'
                {{on 'click' (fn this.toggleEdit)}}
              >
                <PencilSvg class='button-icon' />
                {{t 'components.project_settings.integrations.edit'}}
              </button>
            {{/if}}

            {{#if (get @permissions 'deleteProjectIntegration')}}
              <AsyncButton
                @onClick={{fn this.delete}}
                @loading={{this.isDeleting}}
                class='button button--filled button--white button--hoverRed button--withIcon'
              >
                <XSvg class='button-icon' />
              </AsyncButton>
            {{/if}}
          </div>
        </div>
      {{/if}}
    </li>

    {{#if this.isExecuting}}
      <AccModal @small={{true}} @onClose={{fn this.toggleExecuting}}>
        {{#if this.isAzureStorageContainer}}
          <AzureStorageContainer
            @integration={{@integration}}
            @close={{this.toggleExecuting}}
          />
        {{else if this.isAwsS3}}
          <AwsS3
            @integration={{@integration}}
            @close={{this.toggleExecuting}}
          />
        {{/if}}
      </AccModal>
    {{/if}}

    <style scoped>
      .project-settings-integrations-list-item {
        margin-bottom: 10px;
      }

      .details {
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: flex-start;
        padding: 15px;
        gap: 15px;
        border: 1px solid var(--background-light-highlight);
        border-radius: var(--border-radius);
      }

      .details-info {
        display: flex;
        align-items: center;
        overflow-x: hidden;
        flex: 1 1 auto;
      }

      .details-service {
        font-size: 13px;
        font-weight: bold;
        color: var(--color-black);
      }

      .details-preview {
        padding-right: 15px;
        text-overflow: ellipsis;
        overflow-x: hidden;
        margin-left: 10px;
        font-size: 13px;
        color: var(--color-black);
      }

      .details-last-executed-at {
        margin-left: 5px;
        font-size: 11px;
        opacity: 0.4;
      }

      .details-logo {
        flex: 0 0 20px;
        margin-right: 8px;
        width: 20px;
      }

      .details-actions {
        display: flex;
        gap: 10px;
        flex: 0 0 auto;
      }
    </style>
  </template>
  @service('intl')
  declare intl: IntlService;

  @tracked
  errors = [];

  @tracked
  isEditing = false;

  @tracked
  isDeleting = false;

  @tracked
  isExecuting = false;

  get serviceIsExecutable() {
    return EXECUTABLE_SERVICES.includes(this.args.integration.service);
  }

  get mappedServiceTranslationKey() {
    return `general.integration_services.${this.args.integration.service}`;
  }

  get isAzureStorageContainer() {
    return this.args.integration.service === 'AZURE_STORAGE_CONTAINER';
  }

  get isAwsS3() {
    return this.args.integration.service === 'AWS_S3';
  }

  @action
  toggleExecuting() {
    this.errors = [];
    this.isExecuting = !this.isExecuting;
  }

  @action
  toggleEdit() {
    this.errors = [];
    this.isEditing = !this.isEditing;
  }

  @action
  async update(args: any) {
    const response = await this.args.onUpdate(args);

    this.errors = response.errors;
    this.isEditing = response.errors?.length;

    return response;
  }

  @action
  async delete() {
    const message = this.intl.t(
      'components.project_settings.integrations.delete_confirm'
    );

    // eslint-disable-next-line no-alert
    if (!window.confirm(message)) return;

    this.isDeleting = true;

    const response = await this.args.onDelete({id: this.args.integration.id});

    this.errors = response.errors;
    this.isDeleting = response.errors?.length;

    return response;
  }
}
