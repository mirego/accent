import Component from '@glimmer/component';
import {dropTask} from 'ember-concurrency-decorators';
import IntlService from 'ember-intl/services/intl';
import {inject as service} from '@ember/service';

interface Args {
  project: any;
  prompt: any;
  onDelete: (id: string) => void;
}

export default class ProjectSettingsPromptsItem extends Component<Args> {
  @service('intl')
  intl: IntlService;

  @dropTask
  *deletePrompt() {
    const message = this.intl.t(
      'components.project_settings.prompts.delete_confirm'
    );

    // eslint-disable-next-line no-alert
    if (!window.confirm(message)) {
      return;
    }

    yield this.args.onDelete(this.args.prompt.id);
  }
}
