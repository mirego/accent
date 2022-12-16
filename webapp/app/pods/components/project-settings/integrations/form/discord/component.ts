import Component from '@glimmer/component';
import {action} from '@ember/object';

interface Args {
  repository: any;
  defaultRef: any;
  token: any;
  errors: any;
  url: any;
  project: any;
  events: any;
  onChangeUrl: (url: string) => void;
  onChangeEventsChecked: (events: string[]) => void;
  onChangeRepository: (repository: string) => void;
  onChangeToken: (token: string) => void;
  onChangeDefaultRef: (defaultRef: string) => void;
}

export default class Discord extends Component<Args> {
  @action
  changeUrl(event: Event) {
    const target = event.target as HTMLInputElement;

    this.args.onChangeUrl(target.value);
  }
}
