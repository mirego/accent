import t from 'ember-intl/helpers/t';
import Config from 'accent-webapp/components/project-settings/prompts/config/index';
import Item from 'accent-webapp/components/project-settings/prompts/item/index';
import {LinkTo} from '@ember/routing';
import {array} from '@ember/helper';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import Component from '@glimmer/component';

interface Args {
  project: any;
  prompts?: any;
  onSaveConfig: any;
  onDeleteConfig: any;
  onDeletePrompt: any;
}

export default class ProjectSettingsPrompts extends Component<Args> {
  <template>
    <div class='wrapper'>
      <h2 class='title'>
        {{t 'components.project_settings.prompts.title'}}
      </h2>
      <p class='text'>
        {{t 'components.project_settings.prompts.help'}}
      </p>

      <div class='config'>
        <Config
          @project={{@project}}
          @onSave={{@onSaveConfig}}
          @onDelete={{@onDeleteConfig}}
        />
      </div>

      {{#if @project.promptConfig}}
        <div class='content'>
          {{#if @prompts}}
            <ul class='list'>
              {{#each @prompts as |prompt|}}
                <li>
                  <Item
                    @project={{@project}}
                    @prompt={{prompt}}
                    @onDelete={{@onDeletePrompt}}
                  />
                </li>
              {{/each}}
            </ul>
          {{/if}}

          <LinkTo
            @route='logged-in.project.edit.prompts.new'
            @models={{array @project.id}}
            class='button button--xl button--primary button--highlight'
          >
            {{inlineSvg '/assets/add.svg' class='button-icon'}}
            {{t 'components.project_settings.prompts.new_button'}}
          </LinkTo>
        </div>
      {{/if}}
    </div>
  </template>
}
