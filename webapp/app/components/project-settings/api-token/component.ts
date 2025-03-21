import Component from '@glimmer/component';
import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import {tracked} from '@glimmer/tracking';
import {dropTask} from 'ember-concurrency';
import IntlService from 'ember-intl/services/intl';
import {CreateApiTokenResponse} from 'accent-webapp/queries/create-api-token';

interface Args {
  projectToken: string;
  userToken: string;
  onCreate: (args: {
    name: string;
    pictureUrl: string | null;
    permissions: string[];
  }) => Promise<any>;
  onRevoke: (args: {id: string}) => void;
}

export default class APIToken extends Component<Args> {
  @service('intl')
  intl: IntlService;

  @tracked
  isEdit = false;

  @tracked
  showPermissionsInput = false;

  @tracked
  apiTokenName = '';

  @tracked
  apiTokenPermissions: string[] = [];

  @tracked
  apiTokenPictureUrl: string | null = null;

  @action
  onToggleForm() {
    this.isEdit = !this.isEdit;
  }

  get isSubmitting() {
    return this.submitTask.isRunning;
  }

  get isSubmitDisabled() {
    return !this.apiTokenName || this.apiTokenName.length === 0;
  }

  submitTask = dropTask(async () => {
    if (!this.apiTokenName) return;

    const response: CreateApiTokenResponse = await this.args.onCreate({
      name: this.apiTokenName,
      pictureUrl: this.apiTokenPictureUrl,
      permissions: this.apiTokenPermissions
    });

    if (response.apiToken) {
      this.apiTokenName = '';
      this.apiTokenPictureUrl = '';
      this.showPermissionsInput = false;
      this.unselectAllPermissions();
    }
  });

  @action
  changePermission() {
    this.apiTokenPermissions = Array.from(
      document.querySelectorAll('input[name="permiss"]:checked')
    ).map((input: HTMLInputElement) => input.value);
  }

  @action
  togglePermissionsInput() {
    this.showPermissionsInput = !this.showPermissionsInput;
  }

  @action
  selectAllPermissions() {
    Array.from(document.querySelectorAll('input[name="permiss"]')).forEach(
      (input: HTMLInputElement) => (input.checked = true)
    );

    this.apiTokenPermissions = Array.from(
      document.querySelectorAll('input[name="permiss"]:checked')
    ).map((input: HTMLInputElement) => input.value);
  }

  @action
  unselectAllPermissions() {
    Array.from(document.querySelectorAll('input[name="permiss"]')).forEach(
      (input: HTMLInputElement) => (input.checked = false)
    );
    this.apiTokenPermissions = [];
  }

  @action
  apiTokenNameChanged(event: any) {
    this.apiTokenName = event.target.value;
  }

  @action
  apiTokenPictureUrlChanged(event: any) {
    this.apiTokenPictureUrl = event.target.value;
  }
}
