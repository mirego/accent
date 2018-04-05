import {observer} from '@ember/object';
import {inject as service} from '@ember/service';
import {reads, readOnly, not, and} from '@ember/object/computed';
import Controller from '@ember/controller';

export default Controller.extend({
  session: service(),
  globalState: service('global-state'),

  project: reads('model.project'),
  revisions: reads('project.revisions'),
  permissions: readOnly('globalState.permissions'),
  noProject: not('project'),
  notLoading: not('model.loading'),
  showError: and('noProject', 'notLoading'),

  permissionsObserver: observer('model.permissions', function() {
    this.globalState.set('permissions', this.model.permissions);
  }),

  rolesObserver: observer('model.roles', function() {
    this.globalState.set('roles', this.model.roles);
  }),

  documentFormatsObserver: observer('model.documentFormats', function() {
    this.globalState.set('documentFormats', this.model.documentFormats);
  })
});
