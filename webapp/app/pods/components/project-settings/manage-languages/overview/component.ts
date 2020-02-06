import Component from '@glimmer/component';

interface Args {
  permissions: Record<string, true>;
  project: any;
  revisions: any;
  onPromoteMaster: () => void;
  onDelete: () => void;
}

export default class Overview extends Component<Args> {}
