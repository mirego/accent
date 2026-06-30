import {action} from '@ember/object';
import {service} from '@ember/service';
import {gt, notEmpty} from '@ember/object/computed';
import Component from '@glimmer/component';
import IntlService from 'ember-intl/services/intl';
import GlobalState from 'accent-webapp/services/global-state';
import AccSelect from 'accent-webapp/components/acc-select/index';
import {fn} from '@ember/helper';
import AdvancedFilters from 'accent-webapp/components/revision-export-options/advanced-filters/index';

interface Args {
  format: any;
  onChangeFormat: (format: any) => void;
  orderBy?: any;
  revision?: any;
  revisions?: any;
  document?: any;
  documents?: any;
  version?: any;
  versions?: any;
  isTextEmptyFilter: boolean;
  isAddedLastSyncFilter: boolean;
  isConflictedFilter: boolean;
  onChangeVersion?: (version: any) => void;
  onChangeRevision?: (revision: any) => void;
  onChangeOrderBy?: (orderBy: any) => void;
  onChangeDocument?: (document: any) => void;
  onChangeAdvancedFilterBoolean: () => void;
}

export default class RevisionExportOptions extends Component<Args> {
  <template>
    <div class='revision-export-options'>
      <div class='filters local-filters'>
        <div class='filters-wrapper'>
          <div class='exportOptions'>
            {{#if this.showRevisions}}
              <div class='exportOptions-item'>
                <AccSelect
                  @searchEnabled={{false}}
                  @selected={{this.revisionValue}}
                  @options={{this.mappedRevisions}}
                  @onchange={{fn this.revisionChanged}}
                />
              </div>
            {{/if}}

            {{#if this.showOrders}}
              <div class='exportOptions-item'>
                <AccSelect
                  @searchEnabled={{false}}
                  @selected={{this.orderByValue}}
                  @options={{this.orderByOptions}}
                  @onchange={{fn this.orderByChanged}}
                />
              </div>
            {{/if}}

            <div class='exportOptions-item'>
              <AccSelect
                @searchEnabled={{false}}
                @selected={{this.formatValue}}
                @options={{this.formatOptions}}
                @onchange={{fn this.formatChanged}}
              />
            </div>

            {{#if this.showDocuments}}
              <div class='exportOptions-item'>
                <AccSelect
                  @searchEnabled={{false}}
                  @selected={{this.documentValue}}
                  @options={{this.mappedDocuments}}
                  @onchange={{fn this.documentChanged}}
                />
              </div>
            {{/if}}

            {{#if this.showVersions}}
              <div class='exportOptions-item'>
                <AccSelect
                  @searchEnabled={{false}}
                  @selected={{this.versionValue}}
                  @options={{this.mappedVersions}}
                  @onchange={{fn this.versionChanged}}
                />
              </div>
            {{/if}}
          </div>
        </div>

        {{#if @onChangeAdvancedFilterBoolean}}
          <div class='exportOptions-advancedFilters'>
            <AdvancedFilters
              @isTextEmptyFilter={{@isTextEmptyFilter}}
              @isAddedLastSyncFilter={{@isAddedLastSyncFilter}}
              @isConflictedFilter={{@isConflictedFilter}}
              @onChangeAdvancedFilterBoolean={{@onChangeAdvancedFilterBoolean}}
            />
          </div>
        {{/if}}
      </div>
    </div>
  </template>
  @service('intl')
  declare intl: IntlService;

  @service('global-state')
  declare globalState: GlobalState;

  @notEmpty('args.onChangeOrderBy')
  showOrders: boolean;

  @gt('mappedRevisions.length', 1)
  showRevisions: boolean;

  @gt('mappedDocuments.length', 1)
  showDocuments: boolean;

  @gt('mappedVersions.length', 1)
  showVersions: boolean;

  get orderByValue() {
    return this.orderByOptions.find(({value}) => value === this.args.orderBy);
  }

  get orderByOptions() {
    return [
      {
        value: '',
        label: this.intl.t('components.revision_export_options.orders.original')
      },
      {
        value: 'key',
        label: this.intl.t('components.revision_export_options.orders.az')
      }
    ];
  }

  get formatValue() {
    return this.formatOptions.find(
      ({value}: {value: any}) => value === this.args.format
    );
  }

  get formattedDocumentFormats() {
    if (!this.globalState.documentFormats) return [];

    return this.globalState.documentFormats.map(({slug, name}) => ({
      value: slug,
      label: name
    }));
  }

  get formatOptions() {
    return [
      {
        value: '',
        label: this.intl.t('components.revision_export_options.default_format')
      },
      ...this.formattedDocumentFormats
    ];
  }

  get revisionValue() {
    return (
      this.mappedRevisions.find(
        ({value}: {value: any}) => value === this.args.revision
      ) || this.mappedRevisions[0]
    );
  }

  get mappedRevisions() {
    if (!this.args.revisions) return [];

    return this.args.revisions.map(
      ({
        id,
        name,
        language
      }: {
        id: string;
        name: string | null;
        language: any;
      }) => ({
        label: name || language.name,
        value: id
      })
    );
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
  orderByChanged(orderBy: any) {
    if (orderBy.value === this.args.orderBy) return;

    this.args.onChangeOrderBy?.(orderBy.value);
  }

  @action
  formatChanged(format: any) {
    if (format.value === this.args.format) return;

    this.args.onChangeFormat(format.value);
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
  revisionChanged(revision: any) {
    if (revision.value === this.args.revision) return;

    this.args.onChangeRevision?.(revision.value);
  }
}
