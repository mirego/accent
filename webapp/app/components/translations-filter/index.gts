import {action} from '@ember/object';
import {service} from '@ember/service';
import {gt} from '@ember/object/computed';
import Component from '@glimmer/component';
import IntlService from 'ember-intl/services/intl';
import {tracked} from '@glimmer/tracking';
import {timeout, restartableTask} from 'ember-concurrency';
import {on} from '@ember/modifier';
import {fn} from '@ember/helper';
import FilterSvg from 'accent-webapp/svgs/assets/filter.svg';
import SearchSvg from 'accent-webapp/svgs/assets/search.svg';
import {scopedClass} from 'ember-scoped-css';
import t from 'ember-intl/helpers/t';
import didInsert from '@ember/render-modifiers/modifiers/did-insert';
import onKey from 'ember-keyboard/modifiers/on-key';
import AccSelect from 'accent-webapp/components/acc-select/index';
import AdvancedFilters from 'accent-webapp/components/translations-filter/advanced-filters/index';

const DEBOUNCE_OFFSET = 1000; // ms

interface Args {
  query: string;
  document: any;
  documents: any[];
  version: any;
  versions: any[];
  revisions: any[];
  meta: any;
  withAdvancedFilters: boolean;
  isTextEmptyFilter: boolean;
  isTextNotEmptyFilter: boolean;
  isAddedLastSyncFilter: boolean;
  isCommentedOnFilter: boolean;
  isConflictedFilter: boolean;
  isTranslatedFilter: boolean;
  jipt?: boolean;
  onChangeQuery: (query: string) => void;
  onChangeDocument: () => void;
  onChangeVersion: () => void;
  onChangeAdvancedFilterBoolean: () => void;
}

export default class TranslationsFilter extends Component<Args> {
  <template>
    <div class='translations-filter'>
      <div class='filters {{if @jipt "filters--jipt"}}'>
        <form
          class='filters-wrapper local-filters-wrapper'
          {{on 'submit' (fn this.submitForm)}}
        >
          <div class='filters-content local-filters-content'>
            <div class='queryForm local-queryForm'>
              <div class='queryForm-search'>

                <SearchSvg class={{scopedClass 'search-icon'}} />

                <input
                  type='text'
                  placeholder={{t
                    'components.translations_filter.input_placeholder_text'
                  }}
                  value={{this.debouncedQuery}}
                  class='input'
                  {{didInsert (fn this.autofocus)}}
                  {{onKey 'Enter' (fn this.submitForm)}}
                  {{on 'keyup' (fn this.setDebouncedQuery)}}
                />
              </div>

              {{#if @onChangeAdvancedFilterBoolean}}
                <button
                  type='button'
                  {{on 'click' (fn this.toggleAdvancedFilters)}}
                  class='button button--filled button--white advancedFilters'
                >
                  <FilterSvg class='button-icon' />
                  {{t 'components.translations_filter.advanced_filters_button'}}

                  {{#if @withAdvancedFilters}}
                    <span class='advancedFilters-badge'>
                      {{@withAdvancedFilters}}
                    </span>
                  {{/if}}
                </button>
              {{/if}}
            </div>

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

            {{#if this.displayAdvancedFilters}}
              <AdvancedFilters
                @revisions={{@revisions}}
                @isTextEmptyFilter={{@isTextEmptyFilter}}
                @isTextNotEmptyFilter={{@isTextNotEmptyFilter}}
                @isAddedLastSyncFilter={{@isAddedLastSyncFilter}}
                @isCommentedOnFilter={{@isCommentedOnFilter}}
                @isConflictedFilter={{@isConflictedFilter}}
                @isTranslatedFilter={{@isTranslatedFilter}}
                @onChangeAdvancedFilterBoolean={{@onChangeAdvancedFilterBoolean}}
              />
            {{/if}}
          </div>
        </form>
      </div>
    </div>

    <style scoped>
      .input {
        transition: 0.2s ease-in-out;
        transition-property: background, border, box-shadow;
        resize: vertical;
        outline: 0;
        border-radius: var(--border-radius);
        border: 2px solid var(--input-border-color);
        background: var(--input-background);
        color: var(--input-color);
        font-family: var(--font-monospace);
        line-height: 1.4;
        max-height: 200px;
      }
      .input::-moz-selection {
        background: color-mix(in srgb, var(--color-primary) 70%, transparent);
      }
      .input::selection {
        background: color-mix(in srgb, var(--color-primary) 70%, transparent);
      }
      .input:focus {
        border: 2px solid var(--color-primary);
      }
      .input:disabled {
        color: var(--color-grey);
        background: var(--background-light);
      }

      @media (hover: none) and (max-width: 640px) {
        .input {
          font-size: 16px !important;
        }
      }
      .local-filters-wrapper {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
      }

      .local-queryForm {
        position: relative;
      }

      .queryForm-search {
        width: 100%;
        position: relative;
      }

      .search-icon {
        position: absolute;
        top: 50%;
        margin-top: -10px;
        left: 7px;
        width: 20px;
        height: 20px;
        stroke: var(--input-border-color);
      }

      .input {
        width: 100%;
        padding: 7px 7px 7px 30px;
        font-family: var(--font-primary);
        font-size: 14px;
        color: var(--color-black);
      }
      .input:focus {
        box-shadow:
          inset 0 1px 2px rgba(0, 0, 0, 0.1),
          0 1px 2px var(--shadow-color);
      }
      .input::placeholder {
        color: var(--color-grey);
      }

      button.advancedFilters {
        position: relative;
        box-shadow: none;
        flex-shrink: 0;
      }
      button.advancedFilters:focus,
      button.advancedFilters:hover {
        transform: translate3d(0, 0, 0);
      }

      .advancedFilters-badge {
        position: absolute;
        top: -4px;
        right: -7px;
        background: var(--color-primary);
        border-radius: var(--border-radius);
        padding: 0 4px 1px;
        color: #fff;
        font-size: 10px;
      }

      @media (max-width: 440px) {
        .local-filters-wrapper {
          flex-direction: column;
        }
        .local-queryForm,
        .local-filters-content {
          width: 100%;
        }
      }
    </style>
  </template>
  @service('intl')
  declare intl: IntlService;

  @gt('args.documents.length', 1)
  showDocumentsSelect: boolean;

  @gt('args.versions.length', 0)
  showVersionsSelect: boolean;

  @tracked
  debouncedQuery = this.args.query;

  @tracked
  displayAdvancedFilters = this.args.withAdvancedFilters;

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
        'components.translations_filter.document_default_option_text'
      ),
      value: ''
    });

    return documents;
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
        'components.translations_filter.version_default_option_text'
      ),
      value: ''
    });

    return versions;
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

  debounceQuery = restartableTask(async (query: string) => {
    this.debouncedQuery = query;

    await timeout(DEBOUNCE_OFFSET);

    this.args.onChangeQuery(query);
  });

  @action
  submitForm(event: Event) {
    event.preventDefault();

    this.args.onChangeQuery(this.debouncedQuery);
  }

  @action
  toggleAdvancedFilters() {
    this.displayAdvancedFilters = !this.displayAdvancedFilters;
  }

  @action
  autofocus(input: HTMLInputElement) {
    input.focus();
  }
}
