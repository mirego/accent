import MarkdownIt from 'markdown-it';
import {htmlSafe} from '@ember/string';
import Component from '@glimmer/component';

const markdown = MarkdownIt({
  html: false,
  linkify: true,
  typographer: true,
});

interface Args {
  comment: {
    text: string;
    insertedAt: Date;
    user: {
      fullname: string;
      pictureUrl: string;
    };
  };
}

export default class TranslationsCommentsListItem extends Component<Args> {
  get text() {
    return htmlSafe(markdown.render(this.args.comment.text));
  }
}
