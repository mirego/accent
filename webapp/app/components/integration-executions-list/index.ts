import Component from '@glimmer/component';

interface Args {
  integration: any;
  executions: any[];
}

export default class IntegrationExecutionsList extends Component<Args> {
  get mappedServiceTranslationKey() {
    return `general.integration_services.${this.args.integration?.service}`;
  }
}
