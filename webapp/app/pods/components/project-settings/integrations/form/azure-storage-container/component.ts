import Component from '@glimmer/component';
import {action} from '@ember/object';

interface Args {
  errors: any;
  project: any;
  onChangeSas: (url: string) => void;
}

export default class AzureStorageContainer extends Component<Args> {
  @action
  changeSas(event: Event) {
    const target = event.target as HTMLInputElement;

    this.args.onChangeSas(target.value);
  }
}
