import Component from '@glimmer/component';

interface Args {
  project: any;
  translation: any;
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
      this.args.translation.revision.name ||
      this.args.translation.revision.language.name
    );
  }
}
