import Component from '@glimmer/component';

interface Args {
  project: any;
  permissions: Record<string, true>;
  translation: any;
}

export default class TranslationNavigation extends Component<Args> {}
