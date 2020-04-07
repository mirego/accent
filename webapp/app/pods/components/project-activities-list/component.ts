import Component from '@glimmer/component';

interface Args {
  permissions: Record<string, true>;
  activities: any;
  project: any;
  compact: boolean;
}

export default class ProjectActivitiesList extends Component<Args> {}
