import Component from '@glimmer/component';

interface Args {
  permissions: Record<string, true>;
  documents: any;
  project: any;
  onDelete: (documentEntity: any) => Promise<void>;
  onUpdate: (documentEntity: any, path: string) => Promise<void>;
}

export default class DocumentsList extends Component<Args> {}
