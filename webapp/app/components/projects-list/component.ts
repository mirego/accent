import Component from '@glimmer/component';

interface Args {
  permissions: Record<string, true>;
  projects: any;
  query: any;
}

export default class ProjectsList extends Component<Args> {}
