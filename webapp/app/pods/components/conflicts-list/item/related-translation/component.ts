import Component from '@glimmer/component';
import {action} from '@ember/object';

interface Args {
  project: any;
  translation: any;
  onCopyTranslation: (text: string, languageSlug: string) => void;
}

const MAX_TEXT_LENGTH = 600;

export default class ConflictItemRelatedTranslation extends Component<Args> {
  get text() {
    const text = this.args.translation.correctedText;

    if (text.length < MAX_TEXT_LENGTH) return text;

    return `${text.substring(0, MAX_TEXT_LENGTH - 1)}…`;
  }

  get revisionName() {
    return (
      this.args.translation.revision.slug ||
      this.args.translation.revision.language.slug
    );
  }

  @action
  translate() {
    this.args.onCopyTranslation(
      this.args.translation.correctedText,
      this.revisionSlug
    );
  }

  private get revisionSlug() {
    return (
      this.args.translation.revision.slug ||
      this.args.translation.revision.language.slug
    );
  }
}
