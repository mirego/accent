import {action} from '@ember/object';
import {service} from '@ember/service';
import {not} from '@ember/object/computed';
import Component from '@glimmer/component';
import IntlService from 'ember-intl/services/intl';
import {tracked} from '@glimmer/tracking';

const LOGOS = {
  AZURE_STORAGE_CONTAINER: 'assets/services/azure.svg',
  AWS_S3: 'assets/services/aws-s3.svg',
  DISCORD: 'assets/services/discord.svg',
  GITHUB: 'assets/services/github.svg',
  SLACK: 'assets/services/slack.svg'
};

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

  get logoService() {
    const service: keyof typeof LOGOS = this.service;

    return LOGOS[service];
  }

  get mappedServices() {
    return this.services.map((value) => {
      return {
        label: this.intl.t(`general.integration_services.${value}`),
        value
      };
    });
  }

  get dataFormComponent() {
    return `project-settings/integrations/form/${this.service.toLowerCase()}`;
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
