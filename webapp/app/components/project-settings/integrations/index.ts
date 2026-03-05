import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import {action} from '@ember/object';

interface Args {
  project: any;
  permissions: Record<string, true>;
  showCreateForm: boolean;
  onToggleCreateForm: () => void;
  onCreateIntegration: (args: any) => Promise<{errors: any}>;
  onUpdateIntegration: () => void;
  onDeleteIntegration: () => void;
}

export default class Integrations extends Component<Args> {
  @tracked
  selectedServiceValue: string | null;

  @tracked
  showEmptyDescription = this.args.project.integrations.length === 0;

  @action
  toggleCreateForm(serviceValue: string | PointerEvent) {
    this.selectedServiceValue =
      typeof serviceValue == 'string' ? serviceValue : null;
    this.showEmptyDescription =
      this.args.showCreateForm && this.args.project.integrations.length === 0;
    this.args.onToggleCreateForm();
  }

  @action
  async create(args: any) {
    const response = await this.args.onCreateIntegration(args);

    if (!response.errors?.length) {
      this.args.onToggleCreateForm();
    }

    return response;
  }
}
