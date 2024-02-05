import Component from '@glimmer/component';

interface Args {
  collaborators: any;
  subscriptions: any;
  onCreateSubscription: (user: any) => Promise<void>;
  onDeleteSubscription: (subscription: any) => Promise<void>;
}

export default class TranslationCommentsSubscriptions extends Component<Args> {
  get filteredCollaborators() {
    return this.args.collaborators
      .filter((collaborator: any) => !collaborator.isPending)
      .filter((collaborator: any) => collaborator.role !== 'BOT');
  }
}
