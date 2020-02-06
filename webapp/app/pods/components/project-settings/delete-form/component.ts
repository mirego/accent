import Component from '@glimmer/component';
import {inject as service} from '@ember/service';
import {action} from '@ember/object';
import IntlService from 'ember-intl/services/intl';

interface Args {
  project: any;
  onSubmit: () => void;
}

export default class DeleteForm extends Component<Args> {
  @service('intl')
  intl: IntlService;

  @action
  deleteProject() {
    const message = this.intl.t(
      'components.project_settings.delete_form.delete_project_confirm'
    );

    // eslint-disable-next-line no-alert
    if (!window.confirm(message)) {
      return;
    }

    this.args.onSubmit();
  }
}
