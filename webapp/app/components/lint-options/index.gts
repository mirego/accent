import {action} from '@ember/object';
import {service} from '@ember/service';
import Component from '@glimmer/component';
import IntlService from 'ember-intl/services/intl';
import GlobalState from 'accent-webapp/services/global-state';
import {tracked} from '@glimmer/tracking';
import {timeout, restartableTask} from 'ember-concurrency';
import {on} from '@ember/modifier';
import {fn} from '@ember/helper';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import {scopedClass} from 'ember-scoped-css';
import t from 'ember-intl/helpers/t';
import onKey from 'ember-keyboard/modifiers/on-key';
import AccSelect from 'accent-webapp/components/acc-select/index';

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
  <template>
    <div class='lint-options'>
      <div class='filters filters'>
        <form
          class='filters-wrapper local-filters-wrapper'
          {{on 'submit' (fn this.submitForm)}}
        >
          <div class='filters-content local-filters-content'>
            <div class='queryForm local-queryForm'>
              {{inlineSvg
                '/assets/search.svg'
                class=(scopedClass 'search-icon')
              }}

              <input
                type='text'
                placeholder={{t
                  'components.conflicts_filters.input_placeholder_text'
                }}
                value={{this.debouncedQuery}}
                class='input'
                {{onKey 'Enter' (fn this.submitForm)}}
                {{on 'keyup' this.setDebouncedQuery}}
              />
            </div>

            {{#if this.showSomeFilters}}
              <div class='queryForm-filters'>
                {{#if this.showDocuments}}
                  <div class='queryForm-filters-column'>
                    <div class='exportOptions-item'>
                      <AccSelect
                        @searchEnabled={{false}}
                        @selected={{this.documentValue}}
                        @options={{this.mappedDocuments}}
                        @onchange={{fn this.documentChanged}}
                      />
                    </div>
                  </div>
                {{/if}}

                {{#if this.showVersions}}
                  <div class='queryForm-filters-column'>
                    <div class='exportOptions-item'>
                      <AccSelect
                        @searchEnabled={{false}}
                        @selected={{this.versionValue}}
                        @options={{this.mappedVersions}}
                        @onchange={{fn this.versionChanged}}
                      />
                    </div>
                  </div>
                {{/if}}
              </div>
            {{/if}}
          </div>
        </form>
      </div>
    </div>
  </template>
  @service('intl')
  declare intl: IntlService;

  @service('global-state')
  declare globalState: GlobalState;

  get showDocuments() {
    return this.mappedDocuments.length > 1;
  }

  get showVersions() {
    return this.mappedVersions.length > 1;
  }

  get showSomeFilters() {
    return this.showDocuments || this.showVersions;
  }

  @tracked
  debouncedQuery = this.args.query;

  debounceQuery = restartableTask(async (query: string) => {
    this.debouncedQuery = query;

    await timeout(DEBOUNCE_OFFSET);

    this.args.onChangeQuery(this.debouncedQuery);
  });

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
        value: id
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
            value: tag
          }
        ]),
      [
        {
          label: this.intl.t(
            'components.revision_export_options.default_version'
          ),
          value: ''
        }
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

    this.debounceQuery.perform(target.value);
  }

  @action
  submitForm(event: Event) {
    event.preventDefault();

    this.args.onChangeQuery(this.debouncedQuery);
  }
}
