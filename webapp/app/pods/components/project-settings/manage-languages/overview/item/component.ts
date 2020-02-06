import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import Component from '@glimmer/component';
import IntlService from 'ember-intl/services/intl';
import {tracked} from '@glimmer/tracking';

interface Args {
  master: any;
  permissions: Record<string, true>;
  onPromoteMaster: (revision: any) => Promise<void>;
  onDelete: (revision: any) => Promise<void>;
  project: any;
  revision: any;
}

export default class OverviewItem extends Component<Args> {
  @service('intl')
  intl: IntlService;

  @tracked
  isPromoting = false;

  @tracked
  isDeleting = false;

  @tracked
  isDeleted = false;

  get name() {
    return this.args.revision.name || this.args.revision.language.name;
  }

  get slug() {
    return this.args.revision.slug || this.args.revision.language.slug;
  }

  @action
  async promoteRevision() {
    const message = this.intl.t(
      'components.project_manage_languages_overview.promote_revision_master_confirm'
    );

    // eslint-disable-next-line no-alert
    if (!window.confirm(message)) {
      return;
    }

    this.isPromoting = true;

    await this.args.onPromoteMaster(this.args.revision);

    this.isPromoting = false;
  }

  @action
  async deleteRevision() {
    const message = this.intl.t(
      'components.project_manage_languages_overview.delete_revision_confirm'
    );

    // eslint-disable-next-line no-alert
    if (!window.confirm(message)) {
      return;
    }

    this.isDeleting = true;

    await this.args.onDelete(this.args.revision);

    this.isDeleting = false;
    this.isDeleted = true;
  }
}
