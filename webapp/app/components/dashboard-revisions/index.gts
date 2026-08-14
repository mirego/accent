import {service} from '@ember/service';
import Component from '@glimmer/component';
import percentage from 'accent-webapp/component-helpers/percentage';
import IntlService from 'ember-intl/services/intl';
import ActivitySvg from 'accent-webapp/svgs/assets/activity.svg';
import AddSvg from 'accent-webapp/svgs/assets/add.svg';
import ExportSvg from 'accent-webapp/svgs/assets/export.svg';
import MergeSvg from 'accent-webapp/svgs/assets/merge.svg';
import PercentSvg from 'accent-webapp/svgs/assets/percent.svg';
import SyncSvg from 'accent-webapp/svgs/assets/sync.svg';
import ThumbsUpSvg from 'accent-webapp/svgs/assets/thumbs-up.svg';
import {scopedClass} from 'ember-scoped-css';
import t from 'ember-intl/helpers/t';
import {get, array} from '@ember/helper';
import {LinkTo} from '@ember/routing';
import AccSelect from 'accent-webapp/components/acc-select/index';
import Item from 'accent-webapp/components/dashboard-revisions/item/index';
import WelcomeProject from 'accent-webapp/components/welcome-project/index';
import ProjectLastActivitySync from 'accent-webapp/components/project-last-activity-sync/index';
import ProjectDashboardActivities from 'accent-webapp/components/project-dashboard-activities/index';

const LOW_PERCENTAGE = 50;
const HIGH_PERCENTAGE = 90;

interface Revision {
  id: string;
  isMaster: boolean;
  translationsCount: number;
  conflictsCount: number;
}

interface Document {
  id: string;
  path: string;
}

interface Version {
  id: string;
  tag: string;
}

interface MainRevision {
  id: string;
  reviewedCount: number;
  translationsCount: number;
}

interface Args {
  document: any;
  project: any;
  revisions: Revision[];
  mainRevisions: MainRevision[];
  permissions: Record<string, true>;
  documents: Document[];
  versions: Version[];
  selectedDocument: string | null;
  selectedVersion: string | null;
  showDocumentsSelect: boolean;
  showVersionsSelect: boolean;
  onChangeDocument: (select: HTMLSelectElement) => void;
  onChangeVersion: (select: HTMLSelectElement) => void;
  onCorrectAllConflicts: () => Promise<void>;
  onUncorrectAllConflicts: () => Promise<void>;
  onCorrectAllConflictsFromVersion: () => Promise<void>;
}

const calculateTotalRevisions = (
  revisions: Revision[],
  accumulate: (revision: Revision) => number
) => {
  return revisions.reduce((memo, revision) => {
    return memo + accumulate(revision);
  }, 0);
};

export default class DashboardRevisions extends Component<Args> {
  <template>
    <div
      class='dashboard-revisions
        {{if this.lowPercentage "low-percentage"}}
        {{if this.mediumPercentage "medium-percentage"}}
        {{if this.highPercentage "high-percentage"}}'
    >
      <div class='content'>
        {{#if @project.lastSyncedAt}}
          <div class='numberStat'>
            {{#if this.reviewCompleted}}
              <span class='numberStat-reviewCompleted'>
                <ThumbsUpSvg
                  class={{scopedClass 'numberStat-reviewCompleted-successIcon'}}
                />
                {{t 'components.dashboard_revisions.all_reviewed'}}
              </span>
            {{else}}
              <span class='numberStat-reviewPercentage'>
                {{this.reviewedPercentage}}
                <span class='numberStat-reviewPercentage-unit'>
                  <PercentSvg
                    class={{scopedClass 'numberStat-reviewPercentage-icon'}}
                  />
                </span>
              </span>
            {{/if}}

            <small class='numberStat-totalKeys'>
              {{this.totalReviewed}}
              /
              {{this.totalStrings}}
              <span class='numberStat-totalKeys-label'>
                {{t 'components.dashboard_revisions.strings'}}
              </span>
            </small>
          </div>

          <div class='stats'>
            <h2 class='stats-title'>
              <div class='stats-title-links'>
                {{#if (get @permissions 'sync')}}
                  <LinkTo
                    @route='logged-in.project.files.sync'
                    @models={{array @project.id @document.id}}
                    class='button button--filled button--white'
                  >
                    <SyncSvg class='button-icon' />
                    {{t 'components.documents_list.sync'}}
                  </LinkTo>
                {{/if}}
                {{#if (get @permissions 'merge')}}
                  <LinkTo
                    @route='logged-in.project.files.add-translations'
                    @models={{array @project.id @document.id}}
                    class='button button--borderLess button--filled button--white'
                  >
                    <MergeSvg class='button-icon' />
                    {{t 'components.documents_list.merge'}}
                  </LinkTo>
                {{/if}}
                <LinkTo
                  @route='logged-in.project.files.export'
                  @models={{array @project.id @document.id}}
                  class='button button--borderLess button--filled button--white'
                >
                  <ExportSvg class='button-icon' />
                  {{t 'components.documents_list.export'}}
                </LinkTo>
              </div>
            </h2>

            {{#if this.showFilters}}
              <div class='filters'>
                <div class='queryForm-filters'>
                  {{#if @showDocumentsSelect}}
                    <div class='queryForm-filter'>
                      <div class='queryForm-filter-select'>
                        <AccSelect
                          @searchEnabled={{false}}
                          @selected={{this.mappedDocumentValue}}
                          @options={{this.mappedDocuments}}
                          @onchange={{@onChangeDocument}}
                        />
                      </div>
                    </div>
                  {{/if}}

                  {{#if @showVersionsSelect}}
                    <div class='queryForm-filter'>
                      <div class='queryForm-filter-select'>
                        <AccSelect
                          @searchEnabled={{false}}
                          @selected={{this.mappedVersionValue}}
                          @options={{this.mappedVersions}}
                          @onchange={{@onChangeVersion}}
                        />
                      </div>
                    </div>
                  {{/if}}
                </div>
              </div>
            {{/if}}

            <div class='master'>
              <Item
                @project={{@project}}
                @revision={{this.masterRevision}}
                @mainRevisions={{@mainRevisions}}
                @permissions={{@permissions}}
                @selectedDocument={{@selectedDocument}}
                @selectedVersion={{@selectedVersion}}
                @onCorrectAllConflicts={{@onCorrectAllConflicts}}
                @onUncorrectAllConflicts={{@onUncorrectAllConflicts}}
                @onCorrectAllConflictsFromVersion={{@onCorrectAllConflictsFromVersion}}
              />
            </div>

            {{#if this.slaveRevisions}}
              <div class='slaves'>
                {{#each this.slaveRevisions key='id' as |revision|}}
                  <Item
                    @project={{@project}}
                    @revision={{revision}}
                    @mainRevisions={{@mainRevisions}}
                    @permissions={{@permissions}}
                    @selectedDocument={{@selectedDocument}}
                    @selectedVersion={{@selectedVersion}}
                    @onCorrectAllConflicts={{@onCorrectAllConflicts}}
                    @onUncorrectAllConflicts={{@onUncorrectAllConflicts}}
                    @onCorrectAllConflictsFromVersion={{@onCorrectAllConflictsFromVersion}}
                  />
                {{/each}}
              </div>
            {{else}}
              <div class='empty-slaves'>
                {{#if (get @permissions 'createSlave')}}
                  <LinkTo
                    @route='logged-in.project.manage-languages'
                    @model={{@project.id}}
                    class='empty-slaves-button'
                  >
                    <span class='empty-slaves-button-action'>
                      <AddSvg
                        class={{scopedClass 'empty-slaves-button-icon'}}
                      />
                      {{t
                        'components.dashboard_revisions.new_language_link_title'
                      }}
                    </span>

                    <span class='empty-slaves-button-text'>
                      {{t
                        'components.dashboard_revisions.new_language_link_text'
                      }}
                    </span>
                  </LinkTo>
                {{/if}}
              </div>
            {{/if}}
          </div>
        {{else}}
          <WelcomeProject @project={{@project}} />
        {{/if}}
      </div>

      {{#if @project.lastSyncedAt}}
        <div class='activities'>
          <h2 class='activities-title'>
            <span class='activities-title-text'>
              <ActivitySvg class={{scopedClass 'activities-title-icon'}} />
              {{t 'components.dashboard_revisions.activities_title'}}
            </span>

            <ProjectLastActivitySync @projectId={{@project.id}} />
          </h2>
          <ProjectDashboardActivities
            @projectId={{@project.id}}
            @permissions={{@permissions}}
            @project={{@project}}
          />
          <LinkTo
            @route='logged-in.project.activities'
            @model={{@project.id}}
            class='button button--filled button--white button--borderLess activities-viewMoreButton'
          >
            {{t 'components.dashboard_revisions.view_more_activities'}}
          </LinkTo>
        </div>
      {{/if}}
    </div>

    <style scoped>
      .dashboard-revisions.low-percentage .numberStat-reviewCompleted,
      .dashboard-revisions.low-percentage .numberStat-reviewPercentage {
        color: var(--color-error);
      }

      .dashboard-revisions.medium-percentage .numberStat-reviewCompleted,
      .dashboard-revisions.medium-percentage .numberStat-reviewPercentage {
        color: var(--color-warning);
      }

      .dashboard-revisions.high-percentage .numberStat-reviewCompleted,
      .dashboard-revisions.high-percentage .numberStat-reviewPercentage {
        color: var(--color-success);
      }

      .dashboard-revisions {
        display: flex;
      }

      .dashboard-revisions > .content {
        display: flex;
        align-items: flex-start;
        flex-direction: column;
        width: 100%;
        margin-right: 40px;
        margin-top: 40px;
      }

      .numberStat {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        width: 100%;
        margin: 0 auto 10px;
      }

      .numberStat-reviewPercentage {
        letter-spacing: -3px;
        line-height: 1;
        font-size: 82px;
        font-weight: 400;
      }

      .numberStat-reviewPercentage-icon {
        width: 35px;
        height: 35px;
      }

      .numberStat-reviewPercentage-unit {
        font-size: 62px;
        opacity: 0.7;
      }

      .numberStat-totalKeys {
        display: block;
        font-size: 20px;
        font-family: var(--font-monospace);
        color: #ccc;
      }

      .numberStat-totalKeys-label {
        font-size: 11px;
      }

      .numberStat-reviewCompleted {
        display: flex;
        flex-direction: column;
        align-items: center;
        margin-bottom: 10px;
        font-size: 22px;
      }

      .numberStat-reviewCompleted-successIcon {
        display: block;
        stroke: var(--color-success);
        width: 52px;
        height: 52px;
        margin-bottom: 10px;
      }

      .stats {
        display: flex;
        flex-direction: column;
        width: 100%;
      }

      .stats-title {
        display: flex;
        justify-content: center;
        align-items: center;
        margin-bottom: 10px;
        padding-bottom: 2px;
      }

      .slaves {
        display: flex;
        flex-direction: column;
      }

      .empty-slaves-button {
        display: block;
        width: 100%;
        max-width: 340px;
        padding: 15px;
        background: var(--content-background);
        box-shadow:
          0 1px 4px var(--shadow-color),
          0 7px 12px var(--shadow-color);
        border-radius: var(--border-radius);
        color: var(--color-primary);
        text-decoration: none;
        transition: box-shadow 0.2s ease-in-out;
      }
      .empty-slaves-button:hover,
      .empty-slaves-button:focus {
        box-shadow: 0 3px 10px var(--shadow-color);
      }

      .empty-slaves-button-action {
        display: flex;
        align-items: center;
        font-weight: bold;
        font-size: 12px;
      }

      .empty-slaves-button-icon {
        width: 15px;
        height: 15px;
        margin-right: 5px;
        fill: var(--color-primary);
      }

      .empty-slaves-button-text {
        display: block;
        margin-top: 10px;
        font-size: 11px;
        color: var(--color-black);
        opacity: 0.5;
      }

      .filters {
        margin-top: 5px;
      }

      .master {
        margin: 10px 0 0;
      }

      .stats-title-links {
        display: flex;
        justify-content: flex-end;
        gap: 5px;
      }

      .activities {
        display: flex;
        flex-direction: column;
        max-width: 430px;
        width: 100%;
        margin-top: 40px;
      }

      .activities-title {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 0;
        font-size: 14px;
        font-weight: 300;
      }

      .activities-title-text {
        display: flex;
        align-items: center;
      }

      .activities-title-icon {
        stroke: #bbb;
        width: 15px;
        height: 15px;
        margin-right: 6px;
      }

      .activities-viewMoreButton {
        display: block !important;
        margin-top: 15px !important;
        text-align: center !important;
      }

      .activities-last-sync {
        font-size: 11px;
        text-decoration: none;
        opacity: 0.9;
      }

      @media (max-width: 1024px) {
        .dashboard-revisions {
          flex-direction: column;
        }
        .dashboard-revisions > .content {
          width: 100%;
          margin-right: 0;
        }
        .activities {
          margin-top: 20px;
          max-width: none;
        }
      }
      @media (max-width: 640px) {
        .dashboard-revisions > .content {
          margin: 0;
        }
      }
    </style>
  </template>
  @service('intl')
  declare intl: IntlService;

  get reviewCompleted() {
    return this.reviewedPercentage >= 100;
  }

  get lowPercentage() {
    return this.reviewedPercentage < LOW_PERCENTAGE;
  }

  get mediumPercentage() {
    return this.reviewedPercentage >= LOW_PERCENTAGE;
  }

  get highPercentage() {
    return this.reviewedPercentage >= HIGH_PERCENTAGE;
  }

  get masterRevision() {
    return this.args.revisions.find((revision: Revision) => revision.isMaster);
  }

  get slaveRevisions() {
    return this.args.revisions.filter(
      (revision: Revision) => revision !== this.masterRevision
    );
  }

  get totalStrings() {
    return calculateTotalRevisions(
      this.args.revisions,
      (revision: Revision) => revision.translationsCount
    );
  }

  get totalConflicts() {
    return calculateTotalRevisions(
      this.args.revisions,
      (revision: Revision) => revision.conflictsCount
    );
  }

  get totalReviewed() {
    return calculateTotalRevisions(
      this.args.revisions,
      (revision: Revision) =>
        revision.translationsCount - revision.conflictsCount
    );
  }

  get reviewedPercentage() {
    return percentage(
      this.totalStrings - this.totalConflicts,
      this.totalStrings
    );
  }

  get conflictedPercentage() {
    return percentage(
      this.totalStrings - this.totalReviewed,
      this.totalStrings
    );
  }

  get showFilters() {
    return this.args.showDocumentsSelect || this.args.showVersionsSelect;
  }

  get mappedDocuments() {
    const documents = (this.args.documents || []).map(({id, path}) => ({
      label: path,
      value: id
    }));

    documents.unshift({
      label: this.intl.t('components.dashboard_filters.all_documents'),
      value: ''
    });

    return documents;
  }

  get mappedDocumentValue() {
    return this.mappedDocuments.find(
      ({value}) => value === (this.args.selectedDocument || '')
    );
  }

  get mappedVersions() {
    const versions = (this.args.versions || []).map(({id, tag}) => ({
      label: tag,
      value: id
    }));

    versions.unshift({
      label: this.intl.t('components.dashboard_filters.no_version'),
      value: ''
    });

    return versions;
  }

  get mappedVersionValue() {
    return this.mappedVersions.find(
      ({value}) => value === (this.args.selectedVersion || '')
    );
  }
}
