import Component from '@glimmer/component';

interface Args {
  project: any;
  revision: any;
  permissions: Record<string, true>;
}

export default class DashboardFeaturesList extends Component<Args> {
  get highlightSync() {
    return this.args.revision.translationsCount <= 0;
  }

  get highlightReview() {
    return !this.highlightSync && this.args.revision.conflictsCount > 0;
  }
}
