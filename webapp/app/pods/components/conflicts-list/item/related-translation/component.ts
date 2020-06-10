import Component from '@glimmer/component';

interface Args {
  project: any;
  translation: any;
}

export default class ConflictItemRelatedTranslation extends Component<Args> {
  get revisionName() {
    return (
      this.args.translation.revision.name ||
      this.args.translation.revision.language.name
    );
  }
}
