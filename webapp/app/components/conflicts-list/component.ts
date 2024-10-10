import {tracked} from '@glimmer/tracking';
import {action} from '@ember/object';
import Component from '@glimmer/component';

interface Args {
  permissions: Record<string, true>;
  project: any;
  groupedTranslations: any;
  groupedRevisions: any;
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

export default class ConflictsList extends Component<Args> {
  @tracked
  selectedTranslationId: string | null = null;

  get currentVersion() {
    if (!this.args.versions) return;
    if (!this.args.version) return;

    return this.args.versions.find(
      (version) => version.id === this.args.version
    );
  }

  get mappedRevisions() {
    return this.args.groupedRevisions.map((revision: any) => {
      return {
        name: revision.name || revision.language.name,
        slug: revision.slug || revision.language.slug
      };
    });
  }

  @action
  handleFocus(id: string) {
    this.selectedTranslationId = id;
  }
}
