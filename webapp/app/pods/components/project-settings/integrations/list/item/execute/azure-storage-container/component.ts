import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import {readOnly} from '@ember/object/computed';
import {tracked} from '@glimmer/tracking';
import Component from '@glimmer/component';
import IntlService from 'ember-intl/services/intl';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';
import executeIntegration from 'accent-webapp/queries/execute-integration';

const FLASH_MESSAGE_CREATE_SUCCESS =
  'pods.versions.new.flash_messages.create_success';
const FLASH_MESSAGE_CREATE_ERROR =
  'pods.versions.new.flash_messages.create_error';

interface Args {
  close: () => void;
  integration: {
    id: string;
  };
}

export default class IntegrationExecuteAzureStorageContainer extends Component<Args> {
  @service('intl')
  intl: IntlService;

  @service('apollo-mutate')
  apolloMutate: ApolloMutate;

  @service('flash-messages')
  flashMessages: FlashMessages;

  @readOnly('model.projectModel.project')
  project: any;

  @tracked
  error = false;

  allTargetVersions = [
    {
      value: 'LATEST',
      label:
        'components.project_settings.integrations.execute.azure_storage_container.target_version.options.latest',
    },
    {
      value: 'SPECIFIC',
      label:
        'components.project_settings.integrations.execute.azure_storage_container.target_version.options.specific',
    },
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
  async submit() {
    const confirmMessage = this.intl.t(
      'components.project_settings.integrations.execute.azure_storage_container.submit_confirm'
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
        azureStorageContainer: {
          tag: this.tag,
          targetVersion: this.targetVersion,
        },
      },
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
