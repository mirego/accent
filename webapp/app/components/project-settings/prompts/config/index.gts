import {action} from '@ember/object';
import {service} from '@ember/service';
import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import GlobalState from 'accent-webapp/services/global-state';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import {dropTask} from 'ember-concurrency';
import IntlService from 'ember-intl/services/intl';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import {scopedClass} from 'ember-scoped-css';
import AccSelect from 'accent-webapp/components/acc-select/index';
import {fn} from '@ember/helper';
import {on} from '@ember/modifier';
import t from 'ember-intl/helpers/t';
import AsyncButton from 'accent-webapp/components/async-button/index';
import perform from 'ember-concurrency/helpers/perform';

interface Args {
  project: any;
  onDelete: () => Promise<void>;
  onSave: ({
    provider,
    configKey,
    usePlatform
  }: {
    provider: string;
    configKey: string | null;
    usePlatform: boolean;
  }) => Promise<any>;
}

const PROVIDERS = ['openai'];

/* eslint-disable camelcase */
const LOGOS = {
  openai: 'assets/prompts_providers/openai.svg'
};

export default class ProjectSettingsPromptsConfig extends Component<Args> {
  <template>
    <div class='form {{if @project.promptConfig "form--configured"}}'>
      <div class='provider'>
        {{inlineSvg this.logoProvider class=(scopedClass 'logo')}}

        <AccSelect
          @searchEnabled={{false}}
          @selected={{this.providerValue}}
          @renderInPlace={{true}}
          @options={{this.mappedProviders}}
          @onchange={{fn this.setProvider}}
          class='select'
        />
        {{#if @project.promptConfig}}
          {{inlineSvg 'assets/check.svg' class=(scopedClass 'check')}}
        {{/if}}
      </div>

      <div class='options'>
        <label class='option-checkbox'>
          <input
            value={{this.usePlatform}}
            type='checkbox'
            checked={{this.usePlatform}}
            {{on 'change' (fn this.onUsePlatformChange)}}
          />
          {{t 'components.project_settings.prompts.use_platform_label'}}
        </label>
      </div>

      {{#unless this.usePlatform}}
        <p class='config-key-help'>
          {{#if @project.promptConfig.useConfigKey}}
            {{t 'components.project_settings.prompts.config_key_help_present'}}
          {{else}}
            {{t
              'components.project_settings.prompts.config_key_help_not_present'
            }}
          {{/if}}
        </p>

        <textarea
          placeholder={{this.configKeyPlaceholder}}
          class='textInput'
          {{on 'change' (fn this.onConfigKeyChange)}}
        >{{this.configKey}}</textarea>
      {{/unless}}

      <div class='actions'>
        {{#if @project.promptConfig}}
          <AsyncButton
            @onClick={{perform this.remove}}
            @loading={{this.isRemoving}}
            class='button button--red button--borderless'
          >
            {{t 'components.project_settings.integrations.delete'}}
          </AsyncButton>
        {{/if}}

        <AsyncButton
          @onClick={{perform this.submit}}
          @loading={{this.isSubmitting}}
          class='button button--filled'
        >
          {{t 'components.project_settings.integrations.save'}}
        </AsyncButton>
      </div>
    </div>
  </template>
  @service('global-state')
  declare globalState: GlobalState;

  @service('flash-messages')
  declare flashMessages: FlashMessages;

  @service('intl')
  declare intl: IntlService;

  @tracked
  provider = this.args.project.promptConfig?.provider || 'openai';

  @tracked
  usePlatform = this.args.project.promptConfig?.usePlatform || false;

  @tracked
  configKey: any;

  get providerValue() {
    return this.mappedProviders.find(({value}) => value === this.provider);
  }

  get isSubmitting() {
    return this.submit.isRunning;
  }

  get isRemoving() {
    return this.remove.isRunning;
  }

  get mappedProviders() {
    return PROVIDERS.map((value) => {
      return {
        label: this.intl.t(`general.prompts_providers.${value}`),
        value
      };
    });
  }

  get configKeyPlaceholder() {
    return '••••••••••••••';
  }

  get logoProvider() {
    const provider: keyof typeof LOGOS = this.provider;

    return LOGOS[provider];
  }

  @action
  setProvider({value}: {value: string}) {
    this.provider = value;
  }

  @action
  onConfigKeyChange(event: InputEvent) {
    this.configKey = (event.target as HTMLInputElement).value;
  }

  @action
  onUsePlatformChange(event: InputEvent) {
    const checked = (event.target as HTMLInputElement).checked;

    if (checked) this.configKey = null;
    this.usePlatform = checked;
  }

  submit = dropTask(async () => {
    await this.args.onSave({
      provider: this.provider,
      configKey: this.configKey,
      usePlatform: this.usePlatform
    });
  });

  remove = dropTask(async () => {
    await this.args.onDelete();
  });
}
