import Component from '@glimmer/component';

interface Args {
  project: any;
  permissions: any;
  prompts: any[];
  translations: any;
  onUpdateText: (translation: any, text: string) => Promise<void>;
}
export default class RelatedTranslationsList extends Component<Args> {}
