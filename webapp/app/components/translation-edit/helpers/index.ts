import Component from '@glimmer/component';

interface Args {
  revisions: any[];
}

export default class TranslationEditHelpers extends Component<Args> {
  get machineTranslationLanguages() {
    if (!this.args.revisions) return [];

    return this.args.revisions.map((revision: any) => ({
      name: revision.name || revision.language.name,
      slug: revision.slug || revision.language.slug
    }));
  }
}
