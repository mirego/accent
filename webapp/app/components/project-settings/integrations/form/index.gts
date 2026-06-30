import {action} from '@ember/object';
import {service} from '@ember/service';
import {not} from '@ember/object/computed';
import Component from '@glimmer/component';
import IntlService from 'ember-intl/services/intl';
import {tracked} from '@glimmer/tracking';
import didInsert from '@ember/render-modifiers/modifiers/did-insert';
import {fn} from '@ember/helper';
import didUpdate from '@ember/render-modifiers/modifiers/did-update';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import integrationLogo from 'accent-webapp/helpers/integration-logo';
import {scopedClass} from 'ember-scoped-css';
import AccSelect from 'accent-webapp/components/acc-select/index';
import Slack from 'accent-webapp/components/project-settings/integrations/form/slack/index';
import Discord from 'accent-webapp/components/project-settings/integrations/form/discord/index';
import AzureStorageContainer from 'accent-webapp/components/project-settings/integrations/form/azure-storage-container/index';
import AwsS3 from 'accent-webapp/components/project-settings/integrations/form/aws-s3/index';
import AsyncButton from 'accent-webapp/components/async-button/index';
import t from 'ember-intl/helpers/t';
import {on} from '@ember/modifier';

interface Args {
  selectedServiceValue: string;
  project: any;
  onSubmit: ({
    service,
    events,
    integration,
    data: {url, azureStorageContainerSas}
  }: {
    service: any;
    events: any;
    integration: any;
    data: {
      url: string;
      azureStorageContainerSas: string;
      awsS3Bucket: string;
      awsS3PathPrefix: string;
      awsS3Region: string;
      awsS3AccessKeyId: string;
      awsS3SecretAccessKey: string;
    };
  }) => Promise<{errors: any}>;
  onCancel: () => void;
  integration?: any;
  errors?: any;
}

export default class IntegrationsForm extends Component<Args> {
  <template>
    <div
      class='project-settings-integrations-form'
      {{didInsert (fn this.didUpdateIntegration)}}
      {{didUpdate (fn this.didUpdateIntegration) @integration}}
      {{didInsert (fn this.didUpdateErrors)}}
      {{didUpdate (fn this.didUpdateErrors) @errors}}
    >
      {{#if this.integration}}
        {{#if this.integration.id}}
          <div class='form readonly-service'>
            {{inlineSvg
              (integrationLogo this.service)
              class=(scopedClass 'logo')
            }}
            <span class='logo-label'>{{this.serviceValue.label}}</span>
          </div>
        {{else}}
          <div class='form'>
            {{inlineSvg
              (integrationLogo this.service)
              class=(scopedClass 'logo')
            }}

            <AccSelect
              @searchEnabled={{false}}
              @selected={{this.serviceValue}}
              @renderInPlace={{true}}
              @options={{this.mappedServices}}
              @onchange={{fn this.setService}}
            />
          </div>
        {{/if}}

        <div class='data'>
          {{#if this.isSlack}}
            <Slack
              @errors={{this.errors}}
              @url={{this.url}}
              @events={{this.events}}
              @onChangeUrl={{fn this.setUrl}}
              @onChangeEventsChecked={{fn this.setEventsChecked}}
            />
          {{else if this.isDiscord}}
            <Discord
              @errors={{this.errors}}
              @url={{this.url}}
              @events={{this.events}}
              @onChangeUrl={{fn this.setUrl}}
              @onChangeEventsChecked={{fn this.setEventsChecked}}
            />
          {{else if this.isAzureStorageContainer}}
            <AzureStorageContainer
              @errors={{this.errors}}
              @url={{this.url}}
              @project={{@project}}
              @events={{this.events}}
              @onChangeUrl={{fn this.setUrl}}
              @onChangeSas={{fn this.setAzureStorageContainerSas}}
              @onChangeEventsChecked={{fn this.setEventsChecked}}
            />
          {{else if this.isAwsS3}}
            <AwsS3
              @errors={{this.errors}}
              @bucket={{this.awsS3Bucket}}
              @pathPrefix={{this.awsS3PathPrefix}}
              @region={{this.awsS3Region}}
              @accessKeyId={{this.awsS3AccessKeyId}}
              @project={{@project}}
              @events={{this.events}}
              @onChangeBucket={{fn this.setAwsS3Bucket}}
              @onChangePathPrefix={{fn this.setAwsS3PathPrefix}}
              @onChangeRegion={{fn this.setAwsS3Region}}
              @onChangeAccessKeyId={{fn this.setAwsS3AccessKeyId}}
              @onChangeSecretAccessKey={{fn this.setAwsS3SecretAccessKey}}
              @onChangeEventsChecked={{fn this.setEventsChecked}}
            />
          {{/if}}
        </div>

        <div class='actions'>
          <AsyncButton
            @onClick={{fn this.submit}}
            @loading={{this.isCreating}}
            class='button button--filled'
          >
            {{t 'components.project_settings.integrations.save'}}
          </AsyncButton>

          {{#if @onCancel}}
            <button
              class='button button--filled button--white local-button'
              {{on 'click' (fn @onCancel)}}
            >
              {{t 'components.project_settings.integrations.cancel'}}
            </button>
          {{/if}}
        </div>
      {{/if}}
    </div>
  </template>
  @service('intl')
  declare intl: IntlService;

  @tracked
  isSubmiting = false;

  @tracked
  errors = [];

  @tracked
  integration: any;

  @tracked
  service: any;

  @tracked
  url: string;

  @tracked
  events: string[];

  @tracked
  azureStorageContainerSas: string;

  @tracked
  azureStorageContainerSasBaseUrl: string;

  @tracked
  awsS3Bucket: string;

  @tracked
  awsS3PathPrefix: string;

  @tracked
  awsS3Region: string;

  @tracked
  awsS3AccessKeyId: string;

  @tracked
  awsS3SecretAccessKey: string;

  services = ['AWS_S3', 'AZURE_STORAGE_CONTAINER', 'SLACK', 'DISCORD'];

  @not('url')
  emptyUrl: boolean;

  get serviceValue() {
    return this.mappedServices.find(({value}) => value === this.service);
  }

  get mappedServices() {
    return this.services.map((value) => {
      return {
        label: this.intl.t(`general.integration_services.${value}`),
        value
      };
    });
  }

  get isSlack() {
    return this.service === 'SLACK';
  }

  get isDiscord() {
    return this.service === 'DISCORD';
  }

  get isAzureStorageContainer() {
    return this.service === 'AZURE_STORAGE_CONTAINER';
  }

  get isAwsS3() {
    return this.service === 'AWS_S3';
  }

  @action
  didUpdateIntegration() {
    if (this.args.integration) {
      this.integration = this.args.integration;
    } else {
      this.integration = {
        newRecord: true,
        service: this.args.selectedServiceValue || this.services[0],
        events: [],
        data: {
          url: this.url
        }
      };
    }

    this.service = this.integration.service;
    this.url = this.integration.data.url;
    this.events = this.integration.events;
    this.azureStorageContainerSasBaseUrl = this.integration.data.sasBaseUrl;
    this.awsS3Bucket = this.integration.data.bucket;
    this.awsS3PathPrefix = this.integration.data.pathPrefix;
    this.awsS3Region = this.integration.data.region;
    this.awsS3AccessKeyId = this.integration.data.accessKeyId;
  }

  @action
  didUpdateErrors() {
    this.errors = this.args.errors;
  }

  @action
  setService({value}: {value: string}) {
    this.service = value;
  }

  @action
  setUrl(url: string) {
    this.url = url;
  }

  @action
  setEventsChecked(events: string[]) {
    this.events = events;
  }

  @action
  setAzureStorageContainerSas(value: string) {
    this.azureStorageContainerSas = value;
  }

  @action
  setAwsS3Bucket(value: string) {
    this.awsS3Bucket = value;
  }

  @action
  setAwsS3PathPrefix(value: string) {
    this.awsS3PathPrefix = value;
  }

  @action
  setAwsS3Region(value: string) {
    this.awsS3Region = value;
  }

  @action
  setAwsS3AccessKeyId(value: string) {
    this.awsS3AccessKeyId = value;
  }

  @action
  setAwsS3SecretAccessKey(value: string) {
    this.awsS3SecretAccessKey = value;
  }

  @action
  async submit() {
    this.isSubmiting = true;

    const response = await this.args.onSubmit({
      service: this.service,
      events: this.events,
      integration: this.integration.newRecord ? null : this.integration,
      data: {
        url: this.url,
        azureStorageContainerSas: this.azureStorageContainerSas,
        awsS3Bucket: this.awsS3Bucket,
        awsS3PathPrefix: this.awsS3PathPrefix,
        awsS3Region: this.awsS3Region,
        awsS3AccessKeyId: this.awsS3AccessKeyId,
        awsS3SecretAccessKey: this.awsS3SecretAccessKey
      }
    });

    this.isSubmiting = false;
    this.errors = response.errors;

    return response;
  }
}
