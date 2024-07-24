import {inject as service} from '@ember/service';
import Route from '@ember/routing/route';
import GlobalState from 'accent-webapp/services/global-state';

export default class RevisionRoute extends Route {
  @service('global-state')
  globalState: GlobalState;

  model({revisionId}: {revisionId: string}) {
    this.globalState.revision = revisionId;

    return this.modelFor('logged-in.project');
  }
}
