import {service} from '@ember/service';
import {action} from '@ember/object';
import {readOnly} from '@ember/object/computed';
import {tracked} from '@glimmer/tracking';
import Component from '@glimmer/component';
import IntlService from 'ember-intl/services/intl';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';
import executeIntegration from 'accent-webapp/queries/execute-integration';
import t from 'ember-intl/helpers/t';
import eq from 'ember-truth-helpers/helpers/eq';
import {on} from '@ember/modifier';
import {fn} from '@ember/helper';
import DataControlText from 'accent-webapp/components/project-settings/integrations/form/data-control-text/index';
import AsyncButton from 'accent-webapp/components/async-button/index';
import didInsert from '@ember/render-modifiers/modifiers/did-insert';
import ArrowUpRightSvg from 'accent-webapp/svgs/assets/arrow-up-right.svg';

const FLASH_MESSAGE_CREATE_SUCCESS =
  'pods.project.edit.flash_messages.integration_execute_success';
const FLASH_MESSAGE_CREATE_ERROR =
  'pods.project.edit.flash_messages.integration_execute_error';

interface Args {
  close: () => void;
  integration: {
    id: string;
  };
}

export default class IntegrationExecuteAwsS3 extends Component<Args> {
  <template>
    <div class='aws-push-form'>
      <h1 class='title'>
        {{t 'components.project_settings.integrations.execute.aws_s3.title'}}
      </h1>

      <div class='info'>
        <div>
          <strong>{{t
              'components.project_settings.integrations.execute.aws_s3.bucket'
            }}</strong>
          <span>{{@integration.data.bucket}}</span>
        </div>
        <div>
          <strong>{{t
              'components.project_settings.integrations.execute.aws_s3.path_prefix'
            }}</strong>
          <span>{{@integration.data.pathPrefix}}</span>
        </div>
      </div>

      {{#if this.error}}
        <div class='errors'>
          <div class='error'>
            {{t
              'components.project_settings.integrations.execute.aws_s3.error'
            }}
          </div>
        </div>
      {{/if}}

      <div class='formItem'>
        <div class='data-control'>
          <h3 class='data-title'>
            {{t
              'components.project_settings.integrations.execute.aws_s3.target_version.label'
            }}
          </h3>

          {{#each this.allTargetVersions as |target|}}
            <label class='radio'>
              <input
                type='radio'
                checked={{eq this.targetVersion target.value}}
                name='target_version'
                {{on 'change' (fn this.setTargetVersion target.value)}}
                required
              />
              {{t target.label}}
            </label>
          {{/each}}

          {{#if (eq this.targetVersion 'SPECIFIC')}}
            <DataControlText
              @placeholder='1.0.0'
              @value={{this.tag}}
              @onChange={{this.setTag}}
            />
          {{/if}}
        </div>
      </div>

      <div class='formActions'>
        <AsyncButton
          {{didInsert (fn this.autofocus)}}
          class='button button--filled'
          @loading={{this.isSubmitting}}
          @onClick={{this.submit}}
        >
          <ArrowUpRightSvg class='button-icon' />
          {{t
            'components.project_settings.integrations.execute.aws_s3.push_button'
          }}
        </AsyncButton>
      </div>
    </div>

    <style scoped>
      .textInput {
        transition: 0.2s ease-in-out;
        transition-property: background, border, box-shadow;
        resize: vertical;
        outline: 0;
        border-radius: var(--border-radius);
        border: 2px solid var(--input-border-color);
        background: var(--input-background);
        color: var(--input-color);
        font-family: var(--font-monospace);
        line-height: 1.4;
        max-height: 200px;
      }
      .textInput::-moz-selection {
        background: color-mix(in srgb, var(--color-primary) 70%, transparent);
      }
      .textInput::selection {
        background: color-mix(in srgb, var(--color-primary) 70%, transparent);
      }
      .textInput:focus {
        border: 2px solid var(--color-primary);
      }
      .textInput:disabled {
        color: var(--color-grey);
        background: var(--background-light);
      }

      @media (hover: none) and (max-width: 640px) {
        .textInput {
          font-size: 16px !important;
        }
      }
      .aws-push-form {
        padding: 20px;
        background: var(--content-background);
      }

      .title {
        margin-bottom: 20px;
        text-align: center;
        line-height: 1.2;
        font-size: 27px;
        font-weight: 300;
        color: var(--color-primary);
      }

      .info {
        display: flex;
        flex-direction: column;
        gap: 10px;
        margin-bottom: 10px;
        padding-bottom: 16px;
        border-bottom: 1px solid var(--background-light-highlight);
        font-size: 13px;
      }
      .info div {
        display: flex;
        flex-direction: column;
        gap: 2px;
      }
      .info span {
        font-size: 12px;
        font-family: var(--font-monospace);
        opacity: 0.6;
      }

      .text {
        font-size: 13px;
        margin-bottom: 20px;
        color: #555;
      }

      .textInput {
        flex-grow: 1;
        flex-shrink: 1;
        padding: 10px;
        min-width: 250px;
        width: 100%;
        font-size: 12px;
        font-family: var(--font-primary);
      }

      .errors {
        margin-bottom: 15px;
        padding-bottom: 5px;
      }

      .error {
        margin-bottom: 5px;
        color: var(--color-error);
        font-size: 13px;
        font-weight: bold;
      }

      .formActions {
        display: flex;
        justify-content: flex-end;
        padding-top: 20px;
      }

      .data-control .radio {
        display: inline-flex;
        align-items: center;
        margin-right: 10px;
        border: 1px solid var(--background-light-highlight);
        padding: 4px 6px;
        border-radius: var(--border-radius);
        background: var(--input-background);
        cursor: pointer;
        font-size: 12px;
        transition: 0.2s ease-in-out;
        transition-property: background;
      }
      .data-control .radio:hover,
      .data-control .radio:focus {
        background: var(--background-light);
      }
      .data-control .radio input {
        margin-right: 5px;
        cursor: pointer;
      }

      .data-title {
        display: block;
        margin-bottom: 5px;
        font-size: 13px;
        font-weight: bold;
      }
    </style>
  </template>
  @service('intl')
  declare intl: IntlService;

  @service('apollo-mutate')
  declare apolloMutate: ApolloMutate;

  @service('flash-messages')
  declare flashMessages: FlashMessages;

  @readOnly('model.projectModel.project')
  project: any;

  @tracked
  error = false;

  allTargetVersions = [
    {
      value: 'LATEST',
      label:
        'components.project_settings.integrations.execute.aws_s3.target_version.options.latest'
    },
    {
      value: 'SPECIFIC',
      label:
        'components.project_settings.integrations.execute.aws_s3.target_version.options.specific'
    }
  ];

  @tracked
  targetVersion = this.allTargetVersions[0].value;

  @tracked
  tag: string | null = null;

  @tracked
  isSubmitting = false;

  @action
  setTargetVersion(targetVersion: string) {
    this.tag = null;
    this.targetVersion = targetVersion;
  }

  @action
  setTag(event: Event) {
    const target = event.target as HTMLInputElement;

    this.tag = target.value;
  }

  @action
  autofocus(input: HTMLInputElement) {
    input.focus();
  }

  @action
  async submit() {
    const confirmMessage = this.intl.t(
      'components.project_settings.integrations.execute.aws_s3.submit_confirm'
    );
    /* eslint-disable-next-line no-alert */
    if (!window.confirm(confirmMessage)) {
      return;
    }

    const response = await this.apolloMutate.mutate({
      mutation: executeIntegration,
      refetchQueries: ['ProjectServiceIntegrations'],
      variables: {
        integrationId: this.args.integration.id,
        awsS3: {
          tag: this.tag,
          targetVersion: this.targetVersion
        }
      }
    });

    if (response.errors) {
      this.flashMessages.error(this.intl.t(FLASH_MESSAGE_CREATE_ERROR));
    } else {
      this.args.close();
      this.flashMessages.success(this.intl.t(FLASH_MESSAGE_CREATE_SUCCESS));
    }

    return response;
  }
}
