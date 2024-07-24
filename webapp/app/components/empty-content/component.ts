import Component from '@glimmer/component';

interface Args {
  success?: boolean;
  center?: boolean;
  text: string;
}

export default class EmptyContent extends Component<Args> {}
