import Component from '@glimmer/component';
import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';

interface Args {
  lintTranslation: any;
  project: any;
}

export default class LintTranslationsPageItem extends Component<Args> {
  translationKey = parsedKeyProperty(this.args.lintTranslation.translation.key);

  get showRevisionLink() {
    return this.args.project.revisions.length > 1;
  }

  get revisionName() {
    return (
      this.args.lintTranslation.translation.revision.name ||
      this.args.lintTranslation.translation.revision.language.name
    );
  }
}
