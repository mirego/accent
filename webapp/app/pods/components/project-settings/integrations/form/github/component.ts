import fmt from 'simple-fmt';
import Component from '@glimmer/component';
import {action} from '@ember/object';
import fieldError from 'accent-webapp/computed-macros/field-error';
import config from 'accent-webapp/config/environment';

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

export default class GitHub extends Component<Args> {
  tokenError = fieldError(this.args.errors, this.args.token);
  repositoryError = fieldError(this.args.errors, this.args.repository);
  defaultRefError = fieldError(this.args.errors, this.args.defaultRef);

  get webhookUrl() {
    if (!this.args.project.accessToken) return;

    return fmt(
      config.API.HOOKS_PATH,
      'github',
      this.args.project.id,
      this.args.project.accessToken
    );
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
