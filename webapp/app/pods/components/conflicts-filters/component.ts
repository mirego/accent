import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import {gt} from '@ember/object/computed';
import Component from '@glimmer/component';
import IntlService from 'ember-intl/services/intl';
import {PaginationMeta} from 'accent-webapp/pods/components/resource-pagination/component';
import {tracked} from '@glimmer/tracking';
import {restartableTask} from 'ember-concurrency-decorators';
import {timeout} from 'ember-concurrency';

const DEBOUNCE_OFFSET = 1000; // ms

interface Args {
  meta: PaginationMeta;
  conflicts: any;
  document: any;
  documents: any;
  query: any;
  onChangeDocument: () => void;
  onChangeReference: () => void;
  onChangeQuery: (query: string) => void;
}

export default class ConflictsFilters extends Component<Args> {
  @service('intl')
  intl: IntlService;

  @gt('args.documents.length', 1)
  showDocumentsSelect: boolean;

  @tracked
  debouncedQuery = this.args.query;

  @restartableTask
  *debounceQuery(query: string) {
    this.debouncedQuery = query;

    yield timeout(DEBOUNCE_OFFSET);

    this.args.onChangeQuery(this.debouncedQuery);
  }

  get mappedDocuments() {
    if (!this.args.documents) return [];

    const documents = this.args.documents.map(
      ({id, path}: {id: string; path: string}) => ({
        label: path,
        value: id,
      })
    );

    documents.unshift({
      label: this.intl.t(
        'components.conflicts_filters.document_default_option_text'
      ),
      value: '',
    });

    return documents;
  }

  get documentValue() {
    return this.mappedDocuments.find(
      ({value}: {value: string}) => value === this.args.document
    );
  }

  @action
  setDebouncedQuery(event: Event) {
    const target = event.target as HTMLInputElement;

    // eslint-disable-next-line @typescript-eslint/ban-ts-ignore
    // @ts-ignore
    this.debounceQuery.perform(target.value);
  }

  @action
  submitForm(event: Event) {
    event.preventDefault();

    this.args.onChangeQuery(this.debouncedQuery);
  }
}
