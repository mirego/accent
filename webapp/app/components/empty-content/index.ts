import Component from '@glimmer/component';

interface Args {
  success?: boolean;
  center?: boolean;
  background?: string;
  text: string;
}

export default class EmptyContent extends Component<Args> {
  get isBackgroundPrimary() {
    return this.args.background === 'primary';
  }
}
