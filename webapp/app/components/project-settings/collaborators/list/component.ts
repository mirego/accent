import {action} from '@ember/object';
import Component from '@glimmer/component';

interface Args {
  permissions: Record<string, true>;
  collaborators: any;
  onDelete: (collaborator: any) => void;
  onUpdate: (collaborator: any, args: any) => void;
}

export default class CollaboratorsList extends Component<Args> {
  get filteredCollaborators() {
    return this.args.collaborators.filter((collaborator: any) => {
      return collaborator.isPending || !collaborator.user.isBot;
    });
  }

  @action
  deleteCollaborator(collaborator: any) {
    return this.args.onDelete(collaborator);
  }

  @action
  updateCollaborator(collaborator: any, args: any) {
    return this.args.onUpdate(collaborator, args);
  }
}
