import {action} from '@ember/object';
import {service} from '@ember/service';
import Component from '@glimmer/component';
import Session from 'accent-webapp/services/session';
import RouterService from '@ember/routing/router-service';
import GlobalState from 'accent-webapp/services/global-state';
import {tracked} from '@glimmer/tracking';
import {timeout, restartableTask} from 'ember-concurrency';

const DEBOUNCE_OFFSET = 500; // ms

interface Args {
  session: any;
  project?: any;
}

export default class ProjectsHeader extends Component<Args> {
  @service('session')
  declare session: Session;

  @service('router')
  declare router: RouterService;

  @service('global-state')
  declare globalState: GlobalState;

  @tracked
  debouncedQuery = '';

  get selectedRevision() {
    const selected = this.globalState.revision;

    if (
      selected &&
      this.args.project.revisions
        .map(({id}: {id: string}) => id)
        .includes(selected)
    ) {
      return selected;
    }

    if (!this.args.project.revisions) return;
    return this.args.project.revisions[0].id;
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
  });

  @action
  setDebouncedQuery(event: Event) {
    const target = event.target as HTMLInputElement;

    this.debounceQuery.perform(target.value);
  }

  @action
  logout() {
    this.session.logout();

    window.location.href = '/';
  }
}
