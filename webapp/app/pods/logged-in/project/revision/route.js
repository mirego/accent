import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';

export default Route.extend({
  globalState: service('global-state'),

  model({revisionId}) {
    this.globalState.set('revision', revisionId);

    return this.modelFor('logged-in.project');
  }
});
