import {inject as service} from '@ember/service';
import {readOnly, equal, and} from '@ember/object/computed';
import Controller from '@ember/controller';

export default Controller.extend({
  globalState: service('global-state'),

  permissions: readOnly('globalState.permissions'),
  emptyTranslation: equal('model.translation', undefined),
  showSkeleton: and('emptyTranslation', 'model.loading')
});
