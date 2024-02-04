import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import {action} from '@ember/object';

interface Args {
  project: any;
  permissions: Record<string, true>;
  onCreateIntegration: (args: any) => Promise<{errors: any}>;
  onUpdateIntegration: () => void;
  onDeleteIntegration: () => void;
}

export default class Integrations extends Component<Args> {
  @tracked
  showCreateForm = false;

  @tracked
  selectedServiceValue: string | null;

  @tracked
  showEmptyDescription = this.args.project.integrations.length === 0;

  @action
  toggleCreateForm(serviceValue: string | PointerEvent) {
    this.selectedServiceValue =
      typeof serviceValue == 'string' ? serviceValue : null;
    this.showEmptyDescription =
      this.showCreateForm && this.args.project.integrations.length === 0;
    this.showCreateForm = !this.showCreateForm;
  }

  @action
  async create(args: any) {
    const response = await this.args.onCreateIntegration(args);

    this.showCreateForm = response.errors?.length > 0;

    return response;
  }
}
