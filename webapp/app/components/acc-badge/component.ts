import Component from '@glimmer/component';

interface Args {
  link?: boolean;
  primary?: boolean;
  danger?: boolean;
}

export default class Badge extends Component<Args> {}
