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
import inlineSvg from 'accent-webapp/helpers/inline-svg';

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
          {{inlineSvg '/assets/arrow-up-right.svg' class='button-icon'}}
          {{t
            'components.project_settings.integrations.execute.aws_s3.push_button'
          }}
        </AsyncButton>
      </div>
    </div>
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
