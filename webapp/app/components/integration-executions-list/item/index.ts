import Component from '@glimmer/component';

interface Args {
  execution: {
    id: string;
    state: string;
    data: any;
    results: any;
    insertedAt: string;
    user: {
      id: string;
      email: string;
      fullname: string;
      pictureUrl: string;
    };
    version?: {
      id: string;
      tag: string;
    };
  };
}

export default class IntegrationExecutionsListItem extends Component<Args> {
  get formattedData() {
    if (!this.args.execution.data) return null;
    return JSON.stringify(this.args.execution.data, null, 2);
  }

  get formattedResults() {
    if (!this.args.execution.results) return null;
    return JSON.stringify(this.args.execution.results, null, 2);
  }

  get isSuccess() {
    return this.args.execution.state === 'SUCCESS';
  }
}
