import Component from '@glimmer/component';

interface Args {
  project: any;
  permissions: Record<string, true>;
}

export default class LinksList extends Component<Args> {}
