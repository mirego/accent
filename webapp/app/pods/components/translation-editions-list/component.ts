import Component from '@glimmer/component';

interface Args {
  project: any;
  revisionId: string;
  translations: any;
  onUpdateText: (translation: any, editText: string) => Promise<void>;
}

export default class TranslationEditionsList extends Component<Args> {}
