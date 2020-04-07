import Component from '@glimmer/component';

interface Args {
  project: any;
  revisionId: string;
  translations: any;
  withAdvancedFilters: boolean;
  query: string;
  onUpdateText: (translation: any, editText: string) => Promise<void>;
}

export default class TranslationsList extends Component<Args> {}
