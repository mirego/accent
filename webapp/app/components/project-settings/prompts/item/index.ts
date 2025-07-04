import Component from '@glimmer/component';
import {dropTask} from 'ember-concurrency';
import IntlService from 'ember-intl/services/intl';
import {service} from '@ember/service';

interface Args {
  project: any;
  prompt: any;
  onDelete: (id: string) => Promise<void>;
}

export default class ProjectSettingsPromptsItem extends Component<Args> {
  @service('intl')
  declare intl: IntlService;

  deletePrompt = dropTask(async () => {
    const message = this.intl.t(
      'components.project_settings.prompts.delete_confirm'
    );

    // eslint-disable-next-line no-alert
    if (!window.confirm(message)) {
      return;
    }

    await this.args.onDelete(this.args.prompt.id);
  });
}
