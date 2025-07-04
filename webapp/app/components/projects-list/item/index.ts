import Component from '@glimmer/component';

interface Args {
  project: any;
}

export default class ProjectsListItem extends Component<Args> {
  get colorPrimary() {
    return `--color-primary: ${this.args.project.mainColor}`;
  }
}
