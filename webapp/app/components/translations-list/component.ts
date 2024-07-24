import Component from '@glimmer/component';

interface Args {
  project: any;
  version: any;
  versions: any[];
  revisionId: string;
  translations: any;
  withAdvancedFilters: boolean;
  query: string;
  onUpdateText: (translation: any, editText: string) => Promise<void>;
}

export default class TranslationsList extends Component<Args> {
  get currentVersion() {
    if (!this.args.versions) return;
    if (!this.args.version) return;

    return this.args.versions.find(
      (version) => version.id === this.args.version
    );
  }
}
