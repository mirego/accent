import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import {readOnly} from '@ember/object/computed';
import Controller from '@ember/controller';

import versionUpdateQuery from 'accent-webapp/queries/update-version';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';
import IntlService from 'ember-intl/services/intl';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import RouterService from '@ember/routing/router-service';
import {tracked} from '@glimmer/tracking';

const FLASH_MESSAGE_UPDATE_SUCCESS =
  'pods.versions.edit.flash_messages.update_success';
const FLASH_MESSAGE_UPDATE_ERROR =
  'pods.versions.edit.flash_messages.update_error';

export default class EditController extends Controller {
  @service('apollo-mutate')
  apolloMutate: ApolloMutate;

  @service('intl')
  intl: IntlService;

  @service('router')
  router: RouterService;

  @service('flash-messages')
  flashMessages: FlashMessages;

  @readOnly('model.projectModel.project')
  project: any;

  @readOnly('model.versionModel.documents.entries')
  documents: any;

  @readOnly('model.versionModel.versions.entries')
  versions: any;

  @readOnly('model.versionModel.loading')
  showLoading: boolean;

  @tracked
  error = false;

  get version() {
    if (!this.versions) return;

    return this.versions.find(({id}: {id: string}) => {
      return id === this.model.versionId;
    });
  }

  @action
  closeModal() {
    this.router.transitionTo('logged-in.project.versions', this.project.id);
  }

  @action
  async update({name, tag}: {name: string; tag: string}) {
    this.error = false;

    name = name || '';
    tag = tag || '';

    const id = this.version.id;

    try {
      await this.apolloMutate.mutate({
        mutation: versionUpdateQuery,
        variables: {
          id,
          name,
          tag,
        },
      });

      this.router.transitionTo('logged-in.project.versions', this.project.id);
      this.flashMessages.success(this.intl.t(FLASH_MESSAGE_UPDATE_SUCCESS));
      this.send('closeModal');
    } catch (error) {
      this.error = true;
      this.flashMessages.error(this.intl.t(FLASH_MESSAGE_UPDATE_ERROR));
    }
  }
}
