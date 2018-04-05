import {inject as service} from '@ember/service';
import {readOnly} from '@ember/object/computed';
import Controller from '@ember/controller';

export default Controller.extend({
  globalState: service('global-state'),

  revisions: readOnly('model.project.revisions'),
  revision: readOnly('globalState.revision'),

  actions: {
    selectRevision(revisionId) {
      this.send('onRevisionChange', {revisionId});
    }
  }
});
