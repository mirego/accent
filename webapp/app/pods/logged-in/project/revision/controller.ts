import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import {readOnly} from '@ember/object/computed';
import Controller from '@ember/controller';
import GlobalState from 'accent-webapp/services/global-state';

export default class RevisionController extends Controller {
  @service('global-state')
  globalState: GlobalState;

  @readOnly('model.project.revisions')
  revisions: any;

  @readOnly('globalState.revision')
  revision: any;

  @action
  selectRevision(revisionId: string) {
    this.send('onRevisionChange', {revisionId});
  }
}
