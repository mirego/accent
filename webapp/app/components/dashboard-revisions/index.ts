import {service} from '@ember/service';
import Component from '@glimmer/component';
import percentage from 'accent-webapp/component-helpers/percentage';
import IntlService from 'ember-intl/services/intl';

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
