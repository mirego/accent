import {action} from '@ember/object';
import {service} from '@ember/service';
import {gt} from '@ember/object/computed';
import Component from '@glimmer/component';
import IntlService from 'ember-intl/services/intl';
import {PaginationMeta} from 'accent-webapp/components/resource-pagination';
import {tracked} from '@glimmer/tracking';
import {timeout, restartableTask} from 'ember-concurrency';

const DEBOUNCE_OFFSET = 1000; // ms

interface Args {
  meta: PaginationMeta;
  conflicts: any;
  document: any;
  documents: any;
  relatedRevisions: any;
  defaultRelatedRevisions: any[];
  revisions: any;
  version: any;
  versions: any;
  query: any;
  withAdvancedFilters: boolean;
  onChangeDocument: () => void;
  onChangeVersion: () => void;
  onChangeRevisions: () => void;
  onChangeQuery: (query: string) => void;
}

export default class ConflictsFilters extends Component<Args> {
  @service('intl')
  declare intl: IntlService;

  @gt('args.documents.length', 1)
  showDocumentsSelect: boolean;

  @gt('args.revisions.length', 1)
  showRevisionsSelect: boolean;

  @gt('args.versions.length', 0)
  showVersionsSelect: boolean;

  get showSomeFilters() {
    return this.showDocumentsSelect || this.showVersionsSelect;
  }

  @tracked
  displayAdvancedFilters = this.args.withAdvancedFilters;

  @tracked
  debouncedQuery = this.args.query;

  debounceQuery = restartableTask(async (query: string) => {
    this.debouncedQuery = query;

    await timeout(DEBOUNCE_OFFSET);

    this.args.onChangeQuery(this.debouncedQuery);
  });

  get mappedDocuments() {
    if (!this.args.documents) return [];

    const documents = this.args.documents.map(
      ({id, path}: {id: string; path: string}) => ({
        label: path,
        value: id
      })
    );

    documents.unshift({
      label: this.intl.t(
        'components.conflicts_filters.document_default_option_text'
      ),
      value: ''
    });

    return documents;
  }

  get relatedRevisionsValue() {
    if (this.args.relatedRevisions.length === 0) {
      const revisionIds = this.args.defaultRelatedRevisions.map(
        ({id}: any) => id
      );
      return this.mappedRevisions.filter(({value}: {value: string}) =>
        revisionIds.includes(value)
      );
    }

    return this.args.relatedRevisions
      ?.map((relatedValue: string) => {
        return this.mappedRevisions.find(
          ({value}: {value: string}) => value === relatedValue
        );
      })
      .filter(Boolean);
  }

  get mappedRevisionsOptions() {
    const values = this.relatedRevisionsValue.map(({value}: any) => value);

    return this.mappedRevisions.filter(
      ({value}: {value: string}) => !values.includes(value)
    );
  }

  get documentValue() {
    return this.mappedDocuments.find(
      ({value}: {value: string}) => value === this.args.document
    );
  }

  get mappedVersions() {
    const versions = this.args.versions.map(
      ({id, tag}: {id: string; tag: string}) => ({
        label: tag,
        value: id
      })
    );

    versions.unshift({
      label: this.intl.t(
        'components.conflicts_filters.version_default_option_text'
      ),
      value: ''
    });

    return versions;
  }

  get mappedRevisions() {
    return this.args.revisions.map(
      (revision: {
        id: string;
        name: string | null;
        slug: string | null;
        language: {slug: string; name: string};
      }) => ({
        label: revision.name || revision.language.name,
        value: revision.id
      })
    );
  }

  get versionValue() {
    return this.mappedVersions.find(
      ({value}: {value: string}) => value === this.args.version
    );
  }

  @action
  setDebouncedQuery(event: Event) {
    const target = event.target as HTMLInputElement;

    this.debounceQuery.perform(target.value);
  }

  @action
  toggleAdvancedFilters() {
    this.displayAdvancedFilters = !this.displayAdvancedFilters;
  }

  @action
  submitForm(event: Event) {
    event.preventDefault();

    this.args.onChangeQuery(this.debouncedQuery);
  }

  @action
  autofocus(input: HTMLInputElement) {
    input.focus();
  }
}
