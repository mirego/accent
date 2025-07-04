import Component from '@glimmer/component';

interface Args {
  selectedRevision: any;
  permissions: Record<string, true>;
  project: any;
}

export default class ProjectNavigationList extends Component<Args> {}
