import Component from '@glimmer/component';

interface Args {
  project: any;
  revision: any;
  translations: any;
  isLoading: boolean;
  showLoading: boolean;
  document: any;
  version: any;
  permissions: Record<string, true>;
  documents: any;
  versions: any;
  showSkeleton: boolean;
  query: any;
  reference: any;
  referenceRevision: any;
  referenceRevisions: any;
  onCorrect: () => void;
  onCopyTranslation: () => void;
  onCorrectAll: () => void;
  onSelectPage: () => void;
  onChangeDocument: () => void;
  onChangeVersion: () => void;
  onChangeReference: () => void;
  onChangeQuery: () => void;
}

export default class ConflictsPage extends Component<Args> {}
