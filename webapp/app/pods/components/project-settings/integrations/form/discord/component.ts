import Component from '@glimmer/component';
import {action} from '@ember/object';
import fieldError from 'accent-webapp/computed-macros/field-error';

interface Args {
  repository: any;
  defaultRef: any;
  token: any;
  errors: any;
  url: any;
  project: any;
  syncChecked: any;
  onChangeUrl: (url: string) => void;
  onChangeSyncChecked: (syncChecked: boolean) => void;
  onChangeRepository: (repository: string) => void;
  onChangeToken: (token: string) => void;
  onChangeDefaultRef: (defaultRef: string) => void;
}

export default class Discord extends Component<Args> {
  urlError = fieldError(this.args.errors, this.args.url);

  @action
  changeUrl(event: Event) {
    const target = event.target as HTMLInputElement;

    this.args.onChangeUrl(target.value);
  }
}
