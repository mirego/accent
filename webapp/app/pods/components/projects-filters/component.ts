import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import Component from '@glimmer/component';
import Session from 'accent-webapp/services/session';
import {restartableTask} from 'ember-concurrency-decorators';
import {timeout} from 'ember-concurrency';
import {tracked} from '@glimmer/tracking';

const DEBOUNCE_OFFSET = 1000; // ms

interface Args {
  permissions: any;
  query: any;
  onChangeQuery: (query: string) => void;
}

export default class ProjectsFilter extends Component<Args> {
  @service('session')
  session: Session;

  @tracked
  debouncedQuery: string = this.args.query;

  @action
  setDebouncedQuery(event: Event) {
    const target = event.target as HTMLInputElement;

    // eslint-disable-next-line @typescript-eslint/ban-ts-ignore
    // @ts-ignore
    this.debounceQuery.perform(target.value);
  }

  @restartableTask
  *debounceQuery(query: string) {
    this.debouncedQuery = query;

    yield timeout(DEBOUNCE_OFFSET);

    this.args.onChangeQuery(query);
  }

  @action
  submitForm(event: Event) {
    event.preventDefault();

    this.args.onChangeQuery(this.debouncedQuery);
  }
}
