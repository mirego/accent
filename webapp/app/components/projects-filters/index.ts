import {action} from '@ember/object';
import {service} from '@ember/service';
import Component from '@glimmer/component';
import Session from 'accent-webapp/services/session';
import {timeout, restartableTask} from 'ember-concurrency';
import {tracked} from '@glimmer/tracking';

const DEBOUNCE_OFFSET = 1000; // ms

interface Args {
  permissions: any;
  query: any;
  onChangeQuery: (query: string) => void;
}

export default class ProjectsFilter extends Component<Args> {
  @service('session')
  declare session: Session;

  @tracked
  debouncedQuery: string = this.args.query;

  debounceQueryTask = restartableTask(async (query: string) => {
    this.debouncedQuery = query;

    await timeout(DEBOUNCE_OFFSET);

    this.args.onChangeQuery(query);
  });

  @action
  setDebouncedQuery(event: Event) {
    const target = event.target as HTMLInputElement;

    this.debounceQueryTask.perform(target.value);
  }

  @action
  submitForm(event: Event) {
    event.preventDefault();

    this.args.onChangeQuery(this.debouncedQuery);
  }
}
