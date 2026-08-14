import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import {action} from '@ember/object';
import Form from 'accent-webapp/components/project-settings/integrations/form/index';
import {fn} from '@ember/helper';
import {on} from '@ember/modifier';
import ServicesAwsS3Svg from 'accent-webapp/svgs/assets/services/aws-s3.svg';
import ServicesAzureSvg from 'accent-webapp/svgs/assets/services/azure.svg';
import ServicesDiscordSvg from 'accent-webapp/svgs/assets/services/discord.svg';
import ServicesSlackSvg from 'accent-webapp/svgs/assets/services/slack.svg';
import {scopedClass} from 'ember-scoped-css';
import t from 'ember-intl/helpers/t';
import List from 'accent-webapp/components/project-settings/integrations/list/index';

interface Args {
  project: any;
  permissions: Record<string, true>;
  showCreateForm: boolean;
  onToggleCreateForm: () => void;
  onCreateIntegration: (args: any) => Promise<{errors: any}>;
  onUpdateIntegration: () => void;
  onDeleteIntegration: () => void;
}

export default class Integrations extends Component<Args> {
  <template>
    <div class='project-settings-integrations'>
      {{#if @showCreateForm}}
        <div class='createForm'>
          <Form
            @project={{@project}}
            @selectedServiceValue={{this.selectedServiceValue}}
            @onCancel={{fn this.toggleCreateForm}}
            @onSubmit={{fn this.create}}
          />
        </div>
      {{/if}}

      {{#if this.showEmptyDescription}}
        <div class='empty-description'>
          <button
            class='empty-description-item'
            {{on 'click' (fn this.toggleCreateForm 'AZURE_STORAGE_CONTAINER')}}
          >
            <ServicesAzureSvg class={{scopedClass 'empty-description-icon'}} />
            <strong>{{t
                'components.project_settings.integrations.empty_description.azure_storage_container.title'
              }}</strong>
            <p>{{t
                'components.project_settings.integrations.empty_description.azure_storage_container.text'
              }}</p>
          </button>

          <button
            class='empty-description-item'
            {{on 'click' (fn this.toggleCreateForm 'AWS_S3')}}
          >
            <ServicesAwsS3Svg class={{scopedClass 'empty-description-icon'}} />
            <strong>{{t
                'components.project_settings.integrations.empty_description.aws_s3.title'
              }}</strong>
            <p>{{t
                'components.project_settings.integrations.empty_description.aws_s3.text'
              }}</p>
          </button>

          <button
            class='empty-description-item'
            {{on 'click' (fn this.toggleCreateForm 'SLACK')}}
          >
            <ServicesSlackSvg class={{scopedClass 'empty-description-icon'}} />
            <strong>{{t
                'components.project_settings.integrations.empty_description.slack.title'
              }}</strong>
            <p>{{t
                'components.project_settings.integrations.empty_description.slack.text'
              }}</p>
          </button>

          <button
            class='empty-description-item'
            {{on 'click' (fn this.toggleCreateForm 'DISCORD')}}
          >
            <ServicesDiscordSvg
              class={{scopedClass 'empty-description-icon'}}
            />
            <strong>{{t
                'components.project_settings.integrations.empty_description.discord.title'
              }}</strong>
            <p>{{t
                'components.project_settings.integrations.empty_description.discord.text'
              }}</p>
          </button>
        </div>
      {{/if}}

      <List
        @permissions={{@permissions}}
        @project={{@project}}
        @integrations={{@project.integrations}}
        @onUpdate={{@onUpdateIntegration}}
        @onDelete={{@onDeleteIntegration}}
      />
    </div>

    <style scoped>
      .project-settings-integrations {
        position: relative;
        margin-top: 30px;
      }

      .title {
        display: flex;
        justify-content: space-between;
        align-items: center;
        border-bottom: 1px solid var(--background-light);
        padding-bottom: 6px;
        margin-bottom: 6px;
        color: var(--color-grey);
        font-weight: bold;
        font-size: 17px;
      }

      .empty-description {
        display: grid;
        grid-template-columns: 1fr 1fr 1fr 1fr;
        gap: 30px;
        margin-top: 20px;
      }

      .empty-description-item {
        display: flex;
        flex-direction: column;
        align-items: center;
        text-align: center;
        border: 1px solid var(--background-light-highlight);
        background: var(--background-light);
        color: var(--text-color-normal);
        border-radius: var(--border-radius);
        padding: 20px 30px;
        gap: 2px;
        transition: 0.2s ease-in-out;
        transition-property: box-shadow;
        line-height: 1.4;
      }
      .empty-description-item strong {
        display: block;
      }
      .empty-description-item p {
        font-size: 12px;
        margin-top: 2px;
      }
      .empty-description-item:focus,
      .empty-description-item:hover {
        box-shadow:
          0 1px 6px var(--shadow-color),
          0 2px 19px var(--shadow-color);
      }

      .empty-description-icon {
        width: 50px;
        height: 50px;
        margin: 10px;
      }

      @media (max-width: 1140px) {
        .empty-description {
          grid-template-columns: 1fr 1fr;
          gap: 15px;
        }
      }
      @media (max-width: 540px) {
        .empty-description {
          grid-template-columns: 1fr;
          gap: 10px;
        }
      }
    </style>
  </template>
  @tracked
  selectedServiceValue: string | null;

  @tracked
  showEmptyDescription = this.args.project.integrations.length === 0;

  @action
  toggleCreateForm(serviceValue: string | PointerEvent) {
    this.selectedServiceValue =
      typeof serviceValue == 'string' ? serviceValue : null;
    this.showEmptyDescription =
      this.args.showCreateForm && this.args.project.integrations.length === 0;
    this.args.onToggleCreateForm();
  }

  @action
  async create(args: any) {
    const response = await this.args.onCreateIntegration(args);

    if (!response.errors?.length) {
      this.args.onToggleCreateForm();
    }

    return response;
  }
}
