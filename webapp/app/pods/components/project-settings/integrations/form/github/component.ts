import fmt from 'simple-fmt';
import Component from '@glimmer/component';
import {action} from '@ember/object';
import config from 'accent-webapp/config/environment';

interface Args {
  repository: any;
  defaultRef: any;
  token: any;
  errors: any;
  url: any;
  project: any;
  onChangeUrl: (url: string) => void;
  onChangeRepository: (repository: string) => void;
  onChangeToken: (token: string) => void;
  onChangeDefaultRef: (defaultRef: string) => void;
}

export default class GitHub extends Component<Args> {
  get webhookUrl() {
    const host = window.location.origin;

    return `${host}${fmt(
      config.API.HOOKS_PATH,
      'github',
      this.args.project.id,
      '<YOUR_API_TOKEN_HERE>'
    )}`;
  }

  @action
  changeRepository(event: Event) {
    const target = event.target as HTMLInputElement;

    this.args.onChangeRepository(target.value);
  }

  @action
  changeToken(event: Event) {
    const target = event.target as HTMLInputElement;

    this.args.onChangeToken(target.value);
  }

  @action
  changeDefaultRef(event: Event) {
    const target = event.target as HTMLInputElement;

    this.args.onChangeDefaultRef(target.value);
  }
}
