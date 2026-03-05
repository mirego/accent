import {action} from '@ember/object';
import {service} from '@ember/service';
import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import IntlService from 'ember-intl/services/intl';

const EXECUTABLE_SERVICES = ['AZURE_STORAGE_CONTAINER', 'AWS_S3'];

interface Args {
  project: any;
  permissions: Record<string, true>;
  integration: any;
  onUpdate: (args: any) => Promise<{errors: any}>;
  onDelete: ({id}: {id: string}) => Promise<{errors: any}>;
}

export default class IntegrationsListItem extends Component<Args> {
  @service('intl')
  declare intl: IntlService;

  @tracked
  errors = [];

  @tracked
  isEditing = false;

  @tracked
  isDeleting = false;

  @tracked
  isExecuting = false;

  get serviceIsExecutable() {
    return EXECUTABLE_SERVICES.includes(this.args.integration.service);
  }

  get mappedServiceTranslationKey() {
    return `general.integration_services.${this.args.integration.service}`;
  }

  get dataExecuteComponent() {
    return `project-settings/integrations/list/item/execute/${this.args.integration.service.toLowerCase()}`;
  }

  @action
  toggleExecuting() {
    this.errors = [];
    this.isExecuting = !this.isExecuting;
  }

  @action
  toggleEdit() {
    this.errors = [];
    this.isEditing = !this.isEditing;
  }

  @action
  async update(args: any) {
    const response = await this.args.onUpdate(args);

    this.errors = response.errors;
    this.isEditing = response.errors?.length;

    return response;
  }

  @action
  async delete() {
    const message = this.intl.t(
      'components.project_settings.integrations.delete_confirm'
    );

    // eslint-disable-next-line no-alert
    if (!window.confirm(message)) return;

    this.isDeleting = true;

    const response = await this.args.onDelete({id: this.args.integration.id});

    this.errors = response.errors;
    this.isDeleting = response.errors?.length;

    return response;
  }
}
