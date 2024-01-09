import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import {not} from '@ember/object/computed';
import Component from '@glimmer/component';
import IntlService from 'ember-intl/services/intl';
import {tracked} from '@glimmer/tracking';

const LOGOS = {
  CDN_AZURE: 'assets/services/azure.svg',
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
    data: {url, repository, token, defaultRef},
  }: {
    service: any;
    events: any;
    integration: any;
    data: {
      url: string;
      repository: string;
      token: string;
      defaultRef: string;
      accountName: string;
      accountKey: string;
      containerName: string;
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
  accountName: string;

  @tracked
  accountKey: string;

  @tracked
  containerName: string;

  @tracked
  defaultRef = 'main';

  services = ['CDN_AZURE', 'SLACK', 'GITHUB', 'DISCORD'];

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
          accountName: this.accountName,
          containerName: this.containerName,
        },
      };
    }

    this.service = this.integration.service || this.services[0];
    this.url = this.integration.data.url;
    this.events = this.integration.events;
    this.repository = this.integration.data.repository;
    this.defaultRef = this.integration.data.defaultRef;
    this.accountName = this.integration.data.accountName;
    this.containerName = this.integration.data.containerName;
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
  setAccountName(accountName: string) {
    this.accountName = accountName;
  }

  @action
  setAccountKey(accountKey: string) {
    this.accountKey = accountKey;
  }

  @action
  setContainerName(containerName: string) {
    this.containerName = containerName;
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
        accountName: this.accountName,
        accountKey: this.accountKey,
        containerName: this.containerName,
      },
    });

    this.isSubmiting = false;
    this.errors = response.errors;

    return response;
  }
}
