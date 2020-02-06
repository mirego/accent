import Component from '@glimmer/component';

interface Args {
  permissions: Record<string, true>;
  project: any;
  integrations: any;
  onUpdate: () => void;
  onDelete: () => void;
}

export default class IntegrationsList extends Component<Args> {}
