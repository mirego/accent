import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import {gt} from '@ember/object/computed';
import Component from '@glimmer/component';
import IntlService from 'ember-intl/services/intl';
import GlobalState from 'accent-webapp/services/global-state';
import {tracked} from '@glimmer/tracking';
import {restartableTask} from 'ember-concurrency-decorators';
import {timeout} from 'ember-concurrency';
import {perform} from 'ember-concurrency-ts';

const DEBOUNCE_OFFSET = 1000; // ms

interface Args {
  document?: any;
  documents?: any;
  version?: any;
  versions?: any;
  query?: any;
  onChangeVersion?: (version: any) => void;
  onChangeRevision?: (revision: any) => void;
  onChangeDocument?: (document: any) => void;
  onChangeQuery: (query: string) => void;
}

export default class RevisionExportOptions extends Component<Args> {
  @service('intl')
  intl: IntlService;

  @service('global-state')
  globalState: GlobalState;

  @gt('mappedDocuments.length', 1)
  showDocuments: boolean;

  @gt('mappedVersions.length', 1)
  showVersions: boolean;

  @tracked
  debouncedQuery = this.args.query;

  @restartableTask
  *debounceQuery(query: string) {
    this.debouncedQuery = query;

    yield timeout(DEBOUNCE_OFFSET);

    this.args.onChangeQuery(this.debouncedQuery);
  }

  get documentValue() {
    return (
      this.mappedDocuments.find(
        ({value}: {value: any}) => value === this.args.document
      ) || this.mappedDocuments[0]
    );
  }

  get mappedDocuments() {
    if (!this.args.documents) return [];

    return this.args.documents.map(
      ({id, path}: {id: string; path: string}) => ({
        label: path,
        value: id,
      })
    );
  }

  get versionValue() {
    return this.mappedVersions.find(
      ({value}: {value: any}) => value === this.args.version
    );
  }

  get mappedVersions() {
    if (!this.args.versions) return [];

    return this.args.versions.reduce(
      (memo: object[], {tag}: {tag: string}) =>
        memo.concat([
          {
            label: tag,
            value: tag,
          },
        ]),
      [
        {
          label: this.intl.t(
            'components.revision_export_options.default_version'
          ),
          value: '',
        },
      ]
    );
  }

  @action
  documentChanged(document: any) {
    if (document.value === this.args.document) return;

    this.args.onChangeDocument?.(document.value);
  }

  @action
  versionChanged(version: any) {
    if (version.value === this.args.version) return;

    this.args.onChangeVersion?.(version.value);
  }

  @action
  setDebouncedQuery(event: Event) {
    const target = event.target as HTMLInputElement;

    perform(this.debounceQuery, target.value);
  }

  @action
  submitForm(event: Event) {
    event.preventDefault();

    this.args.onChangeQuery(this.debouncedQuery);
  }
}
