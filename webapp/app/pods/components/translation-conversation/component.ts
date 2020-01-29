import Component from '@glimmer/component';

interface Args {
  permissions: Record<string, true>;
  translation: any;
  collaborators: any;
  subscriptions: any;
  comments: any;
  onCreateSubscription: (user: any) => Promise<void>;
  onDeleteSubscription: (subscription: any) => Promise<void>;
  onSubmit: (text: string) => Promise<void>;
  onSelectPage: (page: number) => void;
}

export default class TranslationConversation extends Component<Args> {}
