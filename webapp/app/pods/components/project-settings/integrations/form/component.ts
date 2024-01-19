import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import {not} from '@ember/object/computed';
import Component from '@glimmer/component';
import IntlService from 'ember-intl/services/intl';
import {tracked} from '@glimmer/tracking';

const LOGOS = {
  AZURE_STORAGE_CONTAINER: 'assets/services/azure.svg',
  DISCORD: 'assets/services/discord.svg',
  GITHUB: 'assets/services/github.svg',
  SLACK: 'assets/services/slack.svg',
};

interface Args {
  project: any;
  onSubmit: ({
    service,
    events,
    integration,
    data: {url, repository, token, defaultRef, azureStorageContainerSas},
  }: {
    service: any;
    events: any;
    integration: any;
    data: {
      url: string;
      repository: string;
      token: string;
      defaultRef: string;
      azureStorageContainerSas: string;
    };
  }) => Promise<{errors: any}>;
  onCancel: () => void;
  integration?: any;
  errors?: any;
}

export default class IntegrationsForm extends Component<Args> {
  @service('intl')
  intl: IntlService;

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
  repository: string;

  @tracked
  token: string;

  @tracked
  azureStorageContainerSas: string;

  @tracked
  azureStorageContainerSasBaseUrl: string;

  @tracked
  defaultRef = 'main';

  services = ['AZURE_STORAGE_CONTAINER', 'SLACK', 'GITHUB', 'DISCORD'];

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
        value,
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
        service: this.services[0],
        events: [],
        data: {
          url: this.url,
          repository: this.repository,
          defaultRef: this.defaultRef,
        },
      };
    }

    this.service = this.integration.service || this.services[0];
    this.url = this.integration.data.url;
    this.events = this.integration.events;
    this.repository = this.integration.data.repository;
    this.defaultRef = this.integration.data.defaultRef;
    this.azureStorageContainerSasBaseUrl = this.integration.data.sasBaseUrl;
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
  setRepository(repository: string) {
    this.repository = repository;
  }

  @action
  setToken(token: string) {
    this.token = token;
  }

  @action
  setDefaultRef(defaultRef: string) {
    this.defaultRef = defaultRef;
  }

  @action
  setAzureStorageContainerSas(sas: string) {
    this.azureStorageContainerSas = sas;
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
        repository: this.repository,
        token: this.token,
        defaultRef: this.defaultRef,
        azureStorageContainerSas: this.azureStorageContainerSas,
      },
    });

    this.isSubmiting = false;
    this.errors = response.errors;

    return response;
  }
}
