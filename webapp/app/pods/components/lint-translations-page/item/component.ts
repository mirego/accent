import Component from '@glimmer/component';
import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';

interface Args {
  lintTranslation: any;
  project: any;
}

export default class LintTranslationsPageItem extends Component<Args> {
  translationKey = parsedKeyProperty(this.args.lintTranslation.translation.key);

  get messages() {
    const mapSet = new Set();
    return this.args.lintTranslation.messages.flatMap((message: any) => {
      if (mapSet.has(message.check)) {
        return [];
      } else {
        mapSet.add(message.check);
        return [message];
      }
    });
  }

  get annotatedText() {
    let offsetTotal = 0;

    return this.args.lintTranslation.messages
      .sort((a: any, b: any) => a.offset || 0 >= b.offset || 0)
      .reduce((text: string, message: any) => {
        if (message.length) {
          const error = text.slice(
            message.offset + offsetTotal,
            message.offset + message.length + offsetTotal
          );

          if (message.replacement) {
            const replacement = `<span data-underline>${error}</span><strong>${message.replacement.label}</strong>`;
            offsetTotal += replacement.length - error.length;

            return String(text).replace(error, replacement);
          } else {
            const replacement = `<span data-underline>${error}</span>`;
            offsetTotal += replacement.length - error.length;

            return String(text).replace(error, replacement);
          }
        } else if (message.check === 'LEADING_SPACES') {
          const replacement = `<span data-rect> </span>`;
          offsetTotal += replacement.length - 1;

          return String(text).replace(/^ /, replacement);
        } else if (message.check === 'TRAILING_SPACE') {
          const replacement = `<span data-rect> </span>`;
          offsetTotal += replacement.length - 1;

          return String(text).replace(/ $/, replacement);
        } else {
          return text;
        }
      }, this.args.lintTranslation.messages[0].text);
  }
}
