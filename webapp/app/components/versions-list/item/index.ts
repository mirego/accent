import {action} from '@ember/object';
import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';

interface Args {
  permissions: Record<string, true>;
  version: any;
  project: any;
  onDelete: (versionEntity: any) => Promise<void>;
}

export default class VersionsListItem extends Component<Args> {
  @tracked
  isDeleting = false;

  @action
  async deleteVersion(version: any) {
    this.isDeleting = true;

    await this.args.onDelete(version);

    this.isDeleting = false;
  }
}
