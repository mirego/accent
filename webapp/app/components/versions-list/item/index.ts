import Component from '@glimmer/component';

interface Args {
  permissions: Record<string, true>;
  version: any;
  project: any;
}

export default class VersionsListItem extends Component<Args> {}
