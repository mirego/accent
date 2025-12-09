import Component from '@glimmer/component';

interface Args {
  permissions: Record<string, true>;
  versions: any;
  project: any;
  onDelete: (versionEntity: any) => Promise<void>;
}

export default class VersionsList extends Component<Args> {}
