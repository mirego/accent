import Component from '@glimmer/component';

interface Args {
  permissions: Record<string, true>;
  projects: any;
}

export default class RecentProjectsList extends Component<Args> {}
