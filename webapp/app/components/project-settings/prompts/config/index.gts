import {action} from '@ember/object';
import {service} from '@ember/service';
import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import GlobalState from 'accent-webapp/services/global-state';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import {dropTask} from 'ember-concurrency';
import IntlService from 'ember-intl/services/intl';
import CheckSvg from 'accent-webapp/svgs/assets/check.svg';
import OpenaiSvg from 'accent-webapp/svgs/assets/prompts_providers/openai.svg';
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

export default class ProjectSettingsPromptsConfig extends Component<Args> {
  <template>
    <div class='form {{if @project.promptConfig "form--configured"}}'>
      <div class='provider'>
        {{#if this.isOpenai}}
          <OpenaiSvg class={{scopedClass 'logo'}} />
        {{/if}}

        <AccSelect
          @searchEnabled={{false}}
          @selected={{this.providerValue}}
          @renderInPlace={{true}}
          @options={{this.mappedProviders}}
          @onchange={{fn this.setProvider}}
          class='select'
        />
        {{#if @project.promptConfig}}
          <CheckSvg class={{scopedClass 'check'}} />
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

    <style scoped>
      .textInput {
        transition: 0.2s ease-in-out;
        transition-property: background, border, box-shadow;
        resize: vertical;
        outline: 0;
        border-radius: var(--border-radius);
        border: 2px solid var(--input-border-color);
        background: var(--input-background);
        color: var(--input-color);
        font-family: var(--font-monospace);
        line-height: 1.4;
        max-height: 200px;
      }
      .textInput::-moz-selection {
        background: color-mix(in srgb, var(--color-primary) 70%, transparent);
      }
      .textInput::selection {
        background: color-mix(in srgb, var(--color-primary) 70%, transparent);
      }
      .textInput:focus {
        border: 2px solid var(--color-primary);
      }
      .textInput:disabled {
        color: var(--color-grey);
        background: var(--background-light);
      }

      @media (hover: none) and (max-width: 640px) {
        .textInput {
          font-size: 16px !important;
        }
      }
      .form {
        padding: 16px;
        border-radius: var(--border-radius);
        background: var(--background-light);
        border: 1px solid var(--background-light-highlight);
      }
      .form.form--configured {
        background: color-mix(in srgb, var(--color-primary) 10%, transparent);
        border-color: color-mix(in srgb, var(--color-primary) 50%, transparent);
      }
      .form.form--configured .config-key-help {
        color: color-mix(in srgb, var(--color-primary) 90%, black);
        opacity: 1;
      }
      .form.form--configured .select select {
        border-color: color-mix(in srgb, var(--color-primary) 50%, transparent);
        background: color-mix(in srgb, var(--color-primary) 10%, transparent);
      }

      .check {
        width: 18px;
        stroke: color-mix(in srgb, var(--color-primary) 90%, black);
      }

      .select {
        flex-grow: 1;
        max-width: 200px;
      }

      .select select {
        border: 1px solid var(--background-light-highlight);
        padding: 7px 10px;
        font-weight: bold;
        font-size: 13px;
      }

      .logo {
        width: 25px;
      }

      .config-key-help {
        margin-top: 10px;
        font-size: 11px;
        padding: 6px 0;
        font-weight: bold;
        opacity: 0.4;
      }

      .provider {
        display: flex;
        align-items: center;
        gap: 16px;
      }

      .textInput {
        flex-grow: 1;
        flex-shrink: 0;
        padding: 8px 10px;
        margin-right: 10px;
        width: 100%;
        font-family: var(--font-monospace);
        font-size: 12px;
      }

      .options {
        margin: 10px 0 0;
        display: flex;
        flex-direction: column;
        gap: 5px;
      }

      .option-checkbox {
        display: flex;
        align-items: center;
        width: 100%;
        gap: 8px;
        font-size: 12px;
        font-weight: bold;
      }

      .actions {
        display: flex;
        justify-content: flex-end;
        gap: 12px;
        margin-top: 6px;
      }
    </style>
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

  get isOpenai() {
    return this.provider === 'openai';
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
