import {inject as service} from '@ember/service';
import {reads, readOnly, equal, and} from '@ember/object/computed';
import Controller from '@ember/controller';

export default Controller.extend({
  intl: service('intl'),
  globalState: service('global-state'),

  project: reads('model.project'),

  permissions: readOnly('globalState.permissions'),

  emptyData: equal('model.project.name', undefined),
  showLoading: and('emptyData', 'model.loading')
});
