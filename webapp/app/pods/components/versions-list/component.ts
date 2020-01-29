import Component from '@glimmer/component';

interface Args {
  permissions: Record<string, true>;
  versions: any;
  project: any;
}

export default class VersionsList extends Component<Args> {}
