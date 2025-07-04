import {service} from '@ember/service';
import {action} from '@ember/object';
import Component from '@glimmer/component';
import GlobalState from 'accent-webapp/services/global-state';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import IntlService from 'ember-intl/services/intl';
import {tracked} from '@glimmer/tracking';

interface Args {
  project: any;
  permissions: Record<string, true>;
  onUpdateProject: ({
    isFileOperationsLocked,
    name,
    mainColor,
    logo
  }: {
    isFileOperationsLocked: boolean;
    name: string;
    mainColor: string;
    logo: string;
  }) => Promise<any>;
}

export default class ProjectSettingsForm extends Component<Args> {
  @service('global-state')
  declare globalState: GlobalState;

  @service('flash-messages')
  declare flashMessages: FlashMessages;

  @service('intl')
  declare intl: IntlService;

  @tracked
  name = this.args.project.name;

  @tracked
  isUpdatingProject = false;

  @tracked
  mainColor = this.args.project.mainColor;

  @tracked
  logo = this.args.project.logo;

  @tracked
  isFileOperationsLocked = this.args.project.isFileOperationsLocked;

  @action
  logoPicked(selection: string) {
    this.logo = selection;
  }

  @action
  async setLockedFileOperations() {
    this.isUpdatingProject = true;
    this.isFileOperationsLocked = !this.isFileOperationsLocked;

    await this.args.onUpdateProject({
      isFileOperationsLocked: this.isFileOperationsLocked,
      name: this.name,
      mainColor: this.mainColor,
      logo: this.logo
    });

    this.isUpdatingProject = false;
  }

  @action
  async updateProject() {
    this.isUpdatingProject = true;

    await this.args.onUpdateProject({
      isFileOperationsLocked: this.isFileOperationsLocked,
      name: this.name,
      mainColor: this.mainColor,
      logo: this.logo
    });

    this.isUpdatingProject = false;
  }

  @action
  logoReset() {
    this.logo = null;
  }

  @action
  setName(event: Event) {
    const target = event.target as HTMLInputElement;

    this.name = target.value;
  }

  @action
  setMainColor(event: Event) {
    const target = event.target as HTMLInputElement;

    this.mainColor = target.value;

    this.globalState.mainColor = this.mainColor;
  }
}
