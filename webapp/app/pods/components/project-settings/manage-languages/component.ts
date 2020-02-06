import Component from '@glimmer/component';

interface Args {
  project: any;
  revisions: any;
  permissions: Record<string, true>;
  languages: any;
  errors: any;
  onPromoteMaster: () => void;
  onDelete: () => void;
  onCreate: () => void;
}

export default class ManageLanguages extends Component<Args> {}
