import Component from '@glimmer/component';

import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';

interface Args {
  project: any;
  translation: any;
  withRevisionLink?: boolean;
}

export default class TranslationSplashTitle extends Component<Args> {
  withRevisionLink = this.args.withRevisionLink ?? true;

  translationKey = parsedKeyProperty(this.args.translation.key);

  get revisionName() {
    return (
      this.args.translation.revision.name ||
      this.args.translation.revision.language.name
    );
  }
}
