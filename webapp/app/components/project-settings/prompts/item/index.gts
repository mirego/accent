import Component from '@glimmer/component';
import {dropTask} from 'ember-concurrency';
import IntlService from 'ember-intl/services/intl';
import {service} from '@ember/service';
import {LinkTo} from '@ember/routing';
import {array} from '@ember/helper';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import AsyncButton from 'accent-webapp/components/async-button/index';
import perform from 'ember-concurrency/helpers/perform';

interface Args {
  project: any;
  prompt: any;
  onDelete: (id: string) => Promise<void>;
}

export default class ProjectSettingsPromptsItem extends Component<Args> {
  <template>
    <div class='wrapper'>
      <strong class='name'>
        {{#if @prompt.quickAccess}}
          <span class='quick-access'>{{@prompt.quickAccess}}</span>
        {{/if}}
        {{@prompt.displayName}}
      </strong>

      <div class='actions'>
        <LinkTo
          @route='logged-in.project.edit.prompts.edit'
          @models={{array @project.id @prompt.id}}
          class='button button--iconOnly button--filled button--white button--link'
        >
          {{inlineSvg 'assets/pencil.svg' class='button-icon'}}
        </LinkTo>
        <AsyncButton
          @onClick={{perform this.deletePrompt}}
          @loading={{this.deletePrompt.isPending}}
          class='button button--iconOnly button--borderless button--red button--small'
        >
          {{inlineSvg 'assets/x.svg' class='button-icon'}}
        </AsyncButton>
      </div>
    </div>
  </template>
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
