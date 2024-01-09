import Component from '@glimmer/component';
import {action} from '@ember/object';

interface Args {
  errors: any;
  project: any;
  accountName: any;
  containerName: any;
  onChangeAccountName: (token: string) => void;
  onChangeAccountKey: (token: string) => void;
  onChangeContainerName: (token: string) => void;
}

export default class CdnAzure extends Component<Args> {
  @action
  changeAccountName(event: Event) {
    const target = event.target as HTMLInputElement;

    this.args.onChangeAccountName(target.value);
  }

  @action
  changeAccountKey(event: Event) {
    const target = event.target as HTMLInputElement;

    this.args.onChangeAccountKey(target.value);
  }

  @action
  changeContainerName(event: Event) {
    const target = event.target as HTMLInputElement;

    this.args.onChangeContainerName(target.value);
  }
}
