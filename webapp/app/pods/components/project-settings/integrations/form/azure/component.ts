import fmt from 'simple-fmt';
import Component from '@glimmer/component';
import {action} from '@ember/object';
import config from 'accent-webapp/config/environment';

interface Args {
  accessKey: any;
  defaultRef: any;
  errors: any;
  project: any;
  secretKey: any;
  targetVersion: any;
  specificVersion: any;
  url: any;
  onChangeAccountName: (token: string) => void;
  onChangeSecretKey: (defaultRef: string) => void;
  onChangeUrl: (url: string) => void;
  onChangeTargetVersion: (url: string) => void;
  onChangeSpecificVersion: (url: string) => void;
}

export default class Azure extends Component<Args> {
  get webhookUrl() {
    const host = window.location.origin;

    return `${host}${fmt(
      config.API.HOOKS_PATH,
      'azure',
      this.args.project.id,
      '<YOUR_API_TOKEN_HERE>'
    )}`;
  }

  @action
  changeAccountName(event: Event) {
    const target = event.target as HTMLInputElement;

    this.args.onChangeAccountName(target.value);
  }

  @action
  changeSecretKey(event: Event) {
    const target = event.target as HTMLInputElement;

    this.args.onChangeSecretKey(target.value);
  }

  @action
  changeUrl(event: Event) {
    const target = event.target as HTMLInputElement;

    this.args.onChangeUrl(target.value);
  }

  @action
  changeTargetVersion(event: Event) {
    const target = event.target as HTMLInputElement;

    this.args.onChangeTargetVersion(target.value);
  }

  @action
  changeSpecificVersion(event: Event) {
    const target = event.target as HTMLInputElement;

    this.args.onChangeTargetVersion(target.value);
  }
}
