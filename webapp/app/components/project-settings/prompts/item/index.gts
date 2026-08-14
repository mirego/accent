import Component from '@glimmer/component';
import {dropTask} from 'ember-concurrency';
import IntlService from 'ember-intl/services/intl';
import {service} from '@ember/service';
import {LinkTo} from '@ember/routing';
import {array} from '@ember/helper';
import PencilSvg from 'accent-webapp/svgs/assets/pencil.svg';
import XSvg from 'accent-webapp/svgs/assets/x.svg';
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
          <PencilSvg class='button-icon' />
        </LinkTo>
        <AsyncButton
          @onClick={{perform this.deletePrompt}}
          @loading={{this.deletePrompt.isPending}}
          class='button button--iconOnly button--borderless button--red button--small'
        >
          <XSvg class='button-icon' />
        </AsyncButton>
      </div>
    </div>

    <style scoped>
      .wrapper {
        padding: 10px 90px 10px 10px;
        border-radius: var(--border-radius);
        border: 1px solid var(--content-background-border);
        font-size: 14px;
        position: relative;
      }

      .name {
        display: flex;
        align-items: center;
        gap: 10px;
      }

      .actions {
        position: absolute;
        top: 0;
        right: 0;
        padding: 8px 10px;
        display: flex;
        gap: 10px;
        align-items: center;
      }

      .quick-access {
        padding: 0 4px;
        border-radius: var(--border-radius);
        display: block;
      }
    </style>
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
