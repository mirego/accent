import Component from '@glimmer/component';

interface Args {
  project: any;
  revision: any;
  translations: any;
  isLoading: boolean;
  showLoading: boolean;
  fullscreen: boolean;
  document: any;
  permissions: Record<string, true>;
  documents: any;
  showSkeleton: boolean;
  query: any;
  reference: any;
  referenceRevision: any;
  referenceRevisions: any;
  onCorrect: () => void;
  onCorrectAll: () => void;
  onSelectPage: () => void;
  onChangeDocument: () => void;
  onChangeReference: () => void;
  onChangeQuery: () => void;
}

export default class ConflictsPage extends Component<Args> {}
