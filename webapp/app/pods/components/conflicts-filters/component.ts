import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import {notEmpty, gt} from '@ember/object/computed';
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
  referenceRevisions: any;
  document: any;
  documents: any;
  query: any;
  reference: any;
  onChangeDocument: () => void;
  onChangeReference: () => void;
  onChangeQuery: (query: string) => void;
}

export default class ConflictsFilters extends Component<Args> {
  @service('intl')
  intl: IntlService;

  @notEmpty('args.referenceRevisions')
  showReferenceRevisionsSelect: boolean;

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
      value: null,
    });

    return documents;
  }

  get mappedReferenceRevisions() {
    const revisions = this.args.referenceRevisions.map(
      ({id, language}: {id: string; language: any}) => ({
        label: language.name,
        value: id,
      })
    );

    revisions.unshift({
      label: this.intl.t(
        'components.conflicts_filters.reference_default_option_text'
      ),
      value: null,
    });

    return revisions;
  }

  get documentValue() {
    return this.mappedDocuments.find(
      ({value}: {value: string}) => value === this.args.document
    );
  }

  get referenceValue() {
    return this.mappedReferenceRevisions.find(({value}: {value: string}) => {
      return value === this.args.reference;
    });
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
