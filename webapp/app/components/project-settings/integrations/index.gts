import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import {action} from '@ember/object';
import Form from 'accent-webapp/components/project-settings/integrations/form/index';
import {fn} from '@ember/helper';
import {on} from '@ember/modifier';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
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
            {{inlineSvg
              'assets/services/azure.svg'
              class=(scopedClass 'empty-description-icon')
            }}
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
            {{inlineSvg
              'assets/services/aws-s3.svg'
              class=(scopedClass 'empty-description-icon')
            }}
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
            {{inlineSvg
              'assets/services/slack.svg'
              class=(scopedClass 'empty-description-icon')
            }}
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
            {{inlineSvg
              'assets/services/discord.svg'
              class=(scopedClass 'empty-description-icon')
            }}
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
