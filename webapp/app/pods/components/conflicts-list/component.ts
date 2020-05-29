import Component from '@glimmer/component';

interface Args {
  permissions: Record<string, true>;
  project: any;
  conflicts: any;
  query: any;
  onCorrect: () => Promise<void>;
}

export default class ConflictsItems extends Component<Args> {}
