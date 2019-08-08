import {inject as service} from '@ember/service';
import {readOnly} from '@ember/object/computed';
import Controller from '@ember/controller';

import versionCreateQuery from 'accent-webapp/queries/create-version';

const FLASH_MESSAGE_CREATE_SUCCESS =
  'pods.versions.new.flash_messages.create_success';
const FLASH_MESSAGE_CREATE_ERROR =
  'pods.versions.new.flash_messages.create_error';

export default Controller.extend({
  apolloMutate: service('apollo-mutate'),
  session: service(),
  i18n: service(),
  flashMessages: service(),

  error: false,
  project: readOnly('model.project'),

  actions: {
    closeModal() {
      this.send('onRefresh');
      this.transitionToRoute('logged-in.project.versions', this.project.id);
    },

    create({name, tag}) {
      this.set('error', false);
      name = name || '';
      tag = tag || '';
      const projectId = this.project.id;

      return this.apolloMutate
        .mutate({
          mutation: versionCreateQuery,
          variables: {
            projectId,
            name,
            tag
          }
        })
        .then(() =>
          this.transitionToRoute('logged-in.project.versions', this.project.id)
        )
        .then(() =>
          this.flashMessages.success(this.i18n.t(FLASH_MESSAGE_CREATE_SUCCESS))
        )
        .then(() => this.send('closeModal'))
        .catch(() => {
          this.set('error', true);
          this.flashMessages.error(this.i18n.t(FLASH_MESSAGE_CREATE_ERROR));
        });
    }
  }
});
