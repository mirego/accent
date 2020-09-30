import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import {not} from '@ember/object/computed';
import Component from '@glimmer/component';
import IntlService from 'ember-intl/services/intl';
import {tracked} from '@glimmer/tracking';

const LOGOS = {
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
  syncChecked: boolean;

  @tracked
  repository: string;

  @tracked
  token: string;

  @tracked
  defaultRef: string;

  services = ['SLACK', 'GITHUB', 'DISCORD'];

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

  get events() {
    return this.syncChecked ? ['SYNC'] : [];
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
          url: '',
          repository: '',
          token: '',
          defaultRef: '',
        },
      };
    }

    this.service = this.integration.service || this.services[0];
    this.url = this.integration.data.url;
    this.syncChecked =
      this.integration.events && this.integration.events.includes('SYNC');
    this.repository = this.integration.data.repository;
    this.token = this.integration.data.token;
    this.defaultRef = this.integration.data.defaultRef;
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
  setSyncChecked(syncChecked: boolean) {
    this.syncChecked = syncChecked;
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
      },
    });

    this.isSubmiting = false;

    if (response.errors && response.errors.length > 0) {
      this.errors = response.errors;
    }
  }
}
