import Component from '@glimmer/component';
import {action} from '@ember/object';
import {tracked} from '@glimmer/tracking';

interface Args {
  project: any;
  permissions: Record<string, true>;
  collaborators: any;
  onCreateCollaborator: () => void;
  onUpdateCollaborator: () => void;
  onDeleteCollaborator: () => void;
}

export default class Collaborators extends Component<Args> {
  @tracked
  showCreateForm = false;

  @action
  toggleCreateForm() {
    this.showCreateForm = !this.showCreateForm;
  }
}
