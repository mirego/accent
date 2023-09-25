import Component from '@glimmer/component';
import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';

interface Args {
  lintTranslation: any;
  project: any;
}

export default class LintTranslationsPageItem extends Component<Args> {
  translationKey = parsedKeyProperty(this.args.lintTranslation.translation.key);

  get annotatedText() {
    return this.args.lintTranslation.messages.reduce(
      (text: string, message: any) => {
        if (message.offset && message.length && message.replacement) {
          const error = text.slice(
            message.offset,
            message.offset + message.length
          );
          return String(text).replace(
            error,
            `<span>${error}</span><strong>${message.replacement.label}</strong>`
          );
        } else {
          return text;
        }
      },
      this.args.lintTranslation.translation.text
    );
  }
}
