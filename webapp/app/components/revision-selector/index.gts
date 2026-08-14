import {action} from '@ember/object';
import {service} from '@ember/service';
import Component from '@glimmer/component';
import IntlService from 'ember-intl/services/intl';
import GlobalState from 'accent-webapp/services/global-state';
import {tracked} from '@glimmer/tracking';
import AccBadge from 'accent-webapp/components/acc-badge/index';
import t from 'ember-intl/helpers/t';
import AccSelect from 'accent-webapp/components/acc-select/index';
import {fn} from '@ember/helper';

interface Args {
  revisions: any;
  revision: any;
  withRevisionsCount: boolean;
  onSelect: (revision: any) => void;
}

export default class RevisionSelector extends Component<Args> {
  <template>
    {{#if this.hasManyRevisions}}
      <div class='revision-selector {{if @jipt "revision-selector--jipt"}}'>
        {{#if @revisions.length}}
          <div class='select'>
            <div class='overlay'>
              <span>
                <strong>{{this.revisionName}}</strong>
                {{#if this.revision.isMaster}}
                  <AccBadge>
                    {{t 'components.revision_selector.master'}}
                  </AccBadge>
                {{/if}}
              </span>

              <span class='otherLanguages'>
                {{t
                  'components.revision_selector.languages_count'
                  count=this.otherRevisionsCount
                }}
              </span>
            </div>
            <AccSelect
              @searchEnabled={{false}}
              @selected={{this.revisionValue}}
              @options={{this.mappedRevisions}}
              @onchange={{fn this.selectRevision}}
            />
          </div>
        {{/if}}
      </div>
    {{/if}}

    <style scoped>
      .revision-selector {
        position: relative;
        margin-bottom: 15px;
      }
      .revision-selector.revision-selector--jipt {
        margin-bottom: 0;
      }
      .revision-selector.revision-selector--jipt .overlay {
        border-radius: 0;
      }
      .revision-selector :global(select) {
        padding: 10px 10px 10px 7px !important;
        padding-bottom: 25px !important;
        border-radius: var(--border-radius) !important;
        font-size: 20px !important;
        flex-direction: row-reverse !important;
        cursor: pointer !important;
        pointer-events: all !important;
        border-color: transparent !important;
      }

      .overlay {
        display: flex;
        flex-direction: column;
        position: absolute;
        top: 0;
        left: 0;
        padding: 10px;
        width: 100%;
        pointer-events: none;
        z-index: 10;
        border-radius: var(--border-radius);
        background: var(--content-background);
        border: 1px solid var(--content-background-border);
      }
      .overlay:hover {
        background: var(--background-light);
      }

      .otherLanguages {
        font-size: 12px;
        color: #ccc;
      }
    </style>
  </template>
  @service('intl')
  declare intl: IntlService;

  @service('global-state')
  declare globalState: GlobalState;

  @tracked
  withRevisionsCount = true;

  get hasManyRevisions() {
    return this.args.revisions && this.args.revisions.length > 1;
  }

  get revisionValue() {
    return this.mappedRevisions.find(
      ({value}: {value: string}) => value === this.args.revision
    );
  }

  get revision() {
    return this.args.revisions.find(({id}: {id: string}) => {
      return id === this.args.revision;
    });
  }

  get masterRevision() {
    return this.args.revisions.find(({isMaster}: {isMaster: boolean}) => {
      return isMaster;
    });
  }

  get revisionName() {
    return this.revision.name || this.revision.language.name;
  }

  get masterRevisionName() {
    return this.masterRevision.name || this.masterRevision.language.name;
  }

  get mappedRevisions() {
    return this.args.revisions.map(
      ({id, name, language}: {id: string; name: string; language: any}) => {
        const displayName = name || language.name;

        return {label: displayName, value: id};
      }
    );
  }

  get otherRevisionsCount() {
    return this.args.revisions && this.args.revisions.length - 1;
  }

  @action
  selectRevision({value}: any) {
    this.globalState.revision = value;

    this.args.onSelect(value);
  }
}
