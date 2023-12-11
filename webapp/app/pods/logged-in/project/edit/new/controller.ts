import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import {readOnly} from '@ember/object/computed';
import {tracked} from '@glimmer/tracking';
import Controller from '@ember/controller';
import IntlService from 'ember-intl/services/intl';
import GlobalState from 'accent-webapp/services/global-state';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import RouterService from '@ember/routing/router-service';

// interface PushStringsProps {
//   targetVersion: string;
//   specificVersion: string | null;
// }

export default class AzurePushController extends Controller {
  @tracked
  model: any;

  @service('intl')
  intl: IntlService;

  @service('global-state')
  globalState: GlobalState;

  @service('flash-messages')
  flashMessages: FlashMessages;

  @service('router')
  router: RouterService;

  @readOnly('model.projectModel.project')
  project: any;

  @tracked
  error = false;

  @action
  closeModal() {
    this.router.transitionTo(
      'logged-in.project.edit.service-integrations',
      this.project.id
    );
  }

  @action
  async pushStrings() {
    // const {targetVersion, specificVersion} = props;

    await this.delay(1000);

    // console.log('TODO: call the pushStrings mutation');
    // console.log(props);

    this.router.transitionTo(
      'logged-in.project.edit.service-integrations',
      this.project.id
    );
  }

  async delay(ms: number) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}
