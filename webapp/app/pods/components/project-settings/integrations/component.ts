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

  @action
  toggleCreateForm() {
    this.showCreateForm = !this.showCreateForm;
  }

  @action
  async create(args: any) {
    const {errors} = await this.args.onCreateIntegration(args);

    this.showCreateForm = errors && errors.length > 0;

    return {errors};
  }
}
