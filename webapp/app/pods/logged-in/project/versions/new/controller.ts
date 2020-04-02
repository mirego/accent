import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import {readOnly} from '@ember/object/computed';
import Controller from '@ember/controller';

import versionCreateQuery from 'accent-webapp/queries/create-version';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';
import Session from 'accent-webapp/services/session';
import IntlService from 'ember-intl/services/intl';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import {tracked} from '@glimmer/tracking';
import RouterService from '@ember/routing/router-service';

const FLASH_MESSAGE_CREATE_SUCCESS =
  'pods.versions.new.flash_messages.create_success';
const FLASH_MESSAGE_CREATE_ERROR =
  'pods.versions.new.flash_messages.create_error';

export default class NewController extends Controller {
  @service('apollo-mutate')
  apolloMutate: ApolloMutate;

  @service('session')
  session: Session;

  @service('router')
  router: RouterService;

  @service('intl')
  intl: IntlService;

  @service('flash-messages')
  flashMessages: FlashMessages;

  @tracked
  error = false;

  @readOnly('model.project')
  project: any;

  @action
  closeModal() {
    this.send('onRefresh');

    this.router.transitionTo('logged-in.project.versions', this.project.id);
  }

  @action
  async create({name, tag}: {name: string; tag: string}) {
    this.error = false;

    name = name || '';
    tag = tag || '';

    const projectId = this.project.id;

    try {
      await this.apolloMutate.mutate({
        mutation: versionCreateQuery,
        variables: {
          projectId,
          name,
          tag,
        },
      });

      this.router.transitionTo('logged-in.project.versions', this.project.id);
      this.flashMessages.success(this.intl.t(FLASH_MESSAGE_CREATE_SUCCESS));
      this.send('closeModal');
    } catch (error) {
      this.error = true;
      this.flashMessages.error(this.intl.t(FLASH_MESSAGE_CREATE_ERROR));
    }
  }
}
