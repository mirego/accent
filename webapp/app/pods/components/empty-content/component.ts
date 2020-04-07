import Component from '@glimmer/component';

interface Args {
  success?: boolean;
  iconPath: string;
  text: string;
}

export default class EmptyContent extends Component<Args> {}
