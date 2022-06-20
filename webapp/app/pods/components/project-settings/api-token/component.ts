import Component from '@glimmer/component';

interface Args {
  projectToken: string;
  userToken: string;
}

export default class APIToken extends Component<Args> {}
