import {action} from '@ember/object';
import {service} from '@ember/service';
import {readOnly} from '@ember/object/computed';
import {tracked} from '@glimmer/tracking';
import Component from '@glimmer/component';
import GlobalState from 'accent-webapp/services/global-state';
import RouterService from '@ember/routing/router-service';
import {timeout, restartableTask} from 'ember-concurrency';
import Session from 'accent-webapp/services/session';

const DEBOUNCE_OFFSET = 500; // ms

interface Args {
  project: any;
  permissions: Record<string, true>;
  revisions: any;
}

export default class ProjectNavigation extends Component<Args> {
  @service('session')
  declare session: Session;

  @service('global-state')
  declare globalState: GlobalState;

  @service('router')
  declare router: RouterService;

  @readOnly('globalState.isProjectNavigationListShowing')
  isListShowing: boolean;

  @tracked
  debouncedQuery = '';

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

  debounceQuery = restartableTask(async (query: string) => {
    this.debouncedQuery = query;
    if (!this.debouncedQuery) return;

    await timeout(DEBOUNCE_OFFSET);

    this.router.transitionTo(
      'logged-in.project.revision.translations',
      this.args.project.id,
      this.selectedRevision,
      {
        queryParams: {query}
      }
    );

    this.debouncedQuery = '';
  });

  @action
  setDebouncedQuery(event: Event) {
    const target = event.target as HTMLInputElement;

    this.debounceQuery.perform(target.value);
  }
}
