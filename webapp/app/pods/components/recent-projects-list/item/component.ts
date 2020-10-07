import Component from '@glimmer/component';

interface Args {
  project: any;
}

export default class RecentProjectsListItem extends Component<Args> {
  get colors() {
    return `
      .projectId-${this.args.project.id} {
        --color-primary: ${this.args.project.mainColor};
      }
    `;
  }
}
