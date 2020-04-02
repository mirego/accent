import {inject as service} from '@ember/service';
import {action} from '@ember/object';
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
  permissions: Record<string, true>;
  integration: any;
  onUpdate: (args: any) => Promise<{errors: any}>;
  onDelete: ({id}: {id: string}) => Promise<{errors: any}>;
}

export default class IntegrationsListItem extends Component<Args> {
  @service('intl')
  intl: IntlService;

  @tracked
  errors = [];

  @tracked
  isEditing = false;

  @tracked
  isDeleting = false;

  get logoService() {
    const service: keyof typeof LOGOS = this.args.integration.service;

    return LOGOS[service];
  }

  get mappedService() {
    return this.intl.t(
      `general.integration_services.${this.args.integration.service}`
    );
  }

  @action
  toggleEdit() {
    this.errors = [];
    this.isEditing = !this.isEditing;
  }

  @action
  async update(args: any) {
    const {errors} = await this.args.onUpdate(args);

    this.errors = errors;
    this.isEditing = errors && errors.length > 0;
  }

  @action
  async delete() {
    this.isDeleting = true;

    const {errors} = await this.args.onDelete({id: this.args.integration.id});

    this.errors = errors;
    this.isDeleting = errors && errors.length > 0;
  }
}
