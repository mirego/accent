import Component from '@glimmer/component';

interface Args {
  project: any;
  permissions: Record<string, true>;
  collaborators: any;
  onCreateCollaborator: () => void;
  onUpdateCollaborator: () => void;
  onDeleteCollaborator: () => void;
}

export default class Collaborators extends Component<Args> {}
