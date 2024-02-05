import {inject as service} from '@ember/service';
import {readOnly} from '@ember/object/computed';
import Component from '@glimmer/component';
import GlobalState from 'accent-webapp/services/global-state';

interface Args {
  project: any;
  permissions: Record<string, true>;
  revisions: any;
}

export default class ProjectNavigation extends Component<Args> {
  @service('global-state')
  globalState: GlobalState;

  @readOnly('globalState.isProjectNavigationListShowing')
  isListShowing: boolean;

  get selectedRevision() {
    const selected = this.globalState.revision;

    if (
      selected &&
      this.args.revisions.map(({id}: {id: string}) => id).includes(selected)
    ) {
      return selected;
    }

    if (!this.args.revisions) return;

    return this.args.revisions[0].id;
  }
}
