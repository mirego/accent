import Component from '@glimmer/component';

interface Args {
  permissions: Record<string, true>;
  project: any;
  conflicts: any;
  version: any;
  versions: any[];
  query: any;
  onCorrect: (conflict: any, textInput: string) => Promise<void>;
  onCopyTranslation: (
    text: string,
    sourceLanguageSlug: string,
    targetLanguageSlug: string
  ) => void;
}

export default class ConflictsItems extends Component<Args> {
  get currentVersion() {
    if (!this.args.versions) return;
    if (!this.args.version) return;

    return this.args.versions.find(
      (version) => version.id === this.args.version
    );
  }
}
