import Component from '@glimmer/component';

interface Args {
  height: string;
  width: string;
}

export default class SkeletonUiContent extends Component<Args> {
  get primaryColor() {
    return 'var(--content-background-border)';
  }

  get secondaryColor() {
    return 'var(--content-background)';
  }
}
