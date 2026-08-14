import Component from '@glimmer/component';
import {service} from '@ember/service';
import {action} from '@ember/object';
import IntlService from 'ember-intl/services/intl';
import AsyncButton from 'accent-webapp/components/async-button/index';
import {fn} from '@ember/helper';

interface Args {
  comment: any;
  onSubmit: () => void;
}

export default class TranslationCommentDelete extends Component<Args> {
  <template>
    <AsyncButton
      @onClick={{fn this.deleteComment}}
      ...attributes
      class='button'
    >
      {{yield}}
    </AsyncButton>

    <style scoped>
      :global(.button.button--small).button :global(.label) {
        padding-left: 4px;
        padding-right: 4px;
      }
    </style>
  </template>
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
