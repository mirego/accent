import {action} from '@ember/object';
import {service} from '@ember/service';
import {gt} from '@ember/object/computed';
import Component from '@glimmer/component';
import IntlService from 'ember-intl/services/intl';
import {PaginationMeta} from 'accent-webapp/components/resource-pagination';
import {tracked} from '@glimmer/tracking';
import {timeout, restartableTask} from 'ember-concurrency';
import t from 'ember-intl/helpers/t';
import {on} from '@ember/modifier';
import {fn} from '@ember/helper';
import AccSelect from 'accent-webapp/components/acc-select/index';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import {scopedClass} from 'ember-scoped-css';
import didInsert from '@ember/render-modifiers/modifiers/did-insert';
import onKey from 'ember-keyboard/modifiers/on-key';
import AdvancedFilters from 'accent-webapp/components/conflicts-list/advanced-filters/index';

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
  <template>
    <div class='conflicts-filters'>
      <div class='filters'>
        {{#if this.showLegendPopup}}
          <div class='legend-container'>
            <span class='legend-icon'>
              ?
            </span>
            <div class='legend-popup'>
              <div class='legend-item'>
                <span class='legend-color legend-color--gray'></span>
                <span>{{t
                    'components.conflicts_filters.legend.to_translate'
                  }}</span>
              </div>
              <div class='legend-item'>
                <span class='legend-color legend-color--yellow'></span>
                <span>{{t
                    'components.conflicts_filters.legend.to_review'
                  }}</span>
              </div>
              <div class='legend-item'>
                <span class='legend-color legend-color--green'></span>
                <span>{{t
                    'components.conflicts_filters.legend.reviewed'
                  }}</span>
              </div>
            </div>
          </div>
        {{/if}}
        <form
          class='filters-wrapper local-filters-wrapper'
          {{on 'submit' (fn this.submitForm)}}
        >
          <div class='filters-content local-filters-content'>

            {{#if this.showRevisionsSelect}}
              <AccSelect
                @matchTriggerWidth={{false}}
                @searchEnabled={{false}}
                @multi={{true}}
                @selected={{this.relatedRevisionsValue}}
                @options={{this.mappedRevisionsOptions}}
                @onchange={{fn @onChangeRevisions}}
              />
            {{/if}}

            <div class='queryForm local-queryForm'>
              <div class='queryForm-search'>
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
                  {{didInsert (fn this.autofocus)}}
                  {{onKey 'Enter' (fn this.submitForm)}}
                  {{on 'keyup' this.setDebouncedQuery}}
                />
              </div>

              {{#if @onChangeAdvancedFilterBoolean}}
                <button
                  {{on 'click' (fn this.toggleAdvancedFilters)}}
                  class='button button--filled button--white advancedFilters'
                >
                  {{inlineSvg 'assets/filter.svg' class='button-icon'}}
                  {{t 'components.conflicts_filters.advanced_filters_button'}}

                  {{#if @withAdvancedFilters}}
                    <span class='advancedFilters-badge'>
                      {{@withAdvancedFilters}}
                    </span>
                  {{/if}}
                </button>
              {{/if}}
            </div>

            {{#if this.showSomeFilters}}
              <div class='queryForm-filters'>
                <div class='queryForm-filters-column'>
                  {{#if this.showDocumentsSelect}}
                    <div class='queryForm-filter'>
                      <div class='queryForm-filter-select'>
                        <AccSelect
                          @matchTriggerWidth={{false}}
                          @searchEnabled={{false}}
                          @selected={{this.documentValue}}
                          @options={{this.mappedDocuments}}
                          @onchange={{fn @onChangeDocument}}
                        />
                      </div>
                    </div>
                  {{/if}}

                  {{#if this.showVersionsSelect}}
                    <div class='queryForm-filter'>
                      <div class='queryForm-filter-select'>
                        <AccSelect
                          @matchTriggerWidth={{false}}
                          @searchEnabled={{false}}
                          @selected={{this.versionValue}}
                          @options={{this.mappedVersions}}
                          @onchange={{fn @onChangeVersion}}
                        />
                      </div>
                    </div>
                  {{/if}}
                </div>
              </div>
            {{/if}}

            {{#if this.displayAdvancedFilters}}
              <AdvancedFilters
                @isTextEmptyFilter={{@isTextEmptyFilter}}
                @isTextNotEmptyFilter={{@isTextNotEmptyFilter}}
                @isAddedLastSyncFilter={{@isAddedLastSyncFilter}}
                @isCommentedOnFilter={{@isCommentedOnFilter}}
                @isTranslatedFilter={{@isTranslatedFilter}}
                @onChangeAdvancedFilterBoolean={{@onChangeAdvancedFilterBoolean}}
              />
            {{/if}}
          </div>
        </form>
      </div>
    </div>
  </template>
  @service('intl')
  declare intl: IntlService;

  @gt('args.conflicts.length', 0)
  showLegendPopup: boolean;

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
