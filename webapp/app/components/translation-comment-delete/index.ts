import Component from '@glimmer/component';
import {service} from '@ember/service';
import {action} from '@ember/object';
import IntlService from 'ember-intl/services/intl';

interface Args {
  comment: any;
  onSubmit: () => void;
}

export default class TranslationCommentDelete extends Component<Args> {
  @service('intl')
  declare intl: IntlService;

  @action
  deleteComment() {
    const message = this.intl.t(
      'components.translation_comment_delete.delete_comment_confirm'
    );

    // eslint-disable-next-line no-alert
    if (!window.confirm(message)) {
      return;
    }

    this.args.onSubmit();
  }
}
