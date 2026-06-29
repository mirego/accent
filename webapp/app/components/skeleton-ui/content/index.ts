import Component from '@glimmer/component';

interface Args {
  height: string;
  width: string;
}

export default class SkeletonUiContent extends Component<Args> {
  get viewBox() {
    return `0 0 ${this.args.width} ${this.args.height}`;
  }

  get primaryColor() {
    return 'var(--content-background-border)';
  }

  get secondaryColor() {
    return 'var(--content-background)';
  }
}
