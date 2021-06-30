import Component from '@glimmer/component';
import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';

interface Args {
  lintTranslation: any;
}

export default class LintTranslationsPageItem extends Component<Args> {
  translationKey = parsedKeyProperty(this.args.lintTranslation.translation.key);
}
