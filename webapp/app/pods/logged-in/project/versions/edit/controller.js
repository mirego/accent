import {computed} from '@ember/object';
import {inject as service} from '@ember/service';
import {reads} from '@ember/object/computed';
import Controller from '@ember/controller';

import versionUpdateQuery from 'accent-webapp/queries/update-version';

const FLASH_MESSAGE_UPDATE_SUCCESS =
  'pods.versions.edit.flash_messages.update_success';
const FLASH_MESSAGE_UPDATE_ERROR =
  'pods.versions.edit.flash_messages.update_error';

export default Controller.extend({
  apolloMutate: service('apollo-mutate'),
  intl: service('intl'),
  flashMessages: service(),

  project: reads('model.projectModel.project'),
  documents: reads('model.versionModel.documents.entries'),
  versions: reads('model.versionModel.versions.entries'),
  showLoading: reads('model.versionModel.loading'),

  version: computed('versions.[]', 'model.versionId', function() {
    if (!this.versions) return;

    return this.versions.find(({id}) => id === this.model.versionId);
  }),

  actions: {
    closeModal() {
      this.transitionToRoute('logged-in.project.versions', this.project.id);
    },

    update({name, tag}) {
      this.set('error', false);
      name = name || '';
      tag = tag || '';
      const id = this.version.id;

      return this.apolloMutate
        .mutate({
          mutation: versionUpdateQuery,
          variables: {
            id,
            name,
            tag
          }
        })
        .then(() =>
          this.transitionToRoute('logged-in.project.versions', this.project.id)
        )
        .then(() =>
          this.flashMessages.success(this.intl.t(FLASH_MESSAGE_UPDATE_SUCCESS))
        )
        .then(() => this.send('closeModal'))
        .catch(() => {
          this.set('error', true);
          this.flashMessages.error(this.intl.t(FLASH_MESSAGE_UPDATE_ERROR));
        });
    }
  }
});
