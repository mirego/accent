import {action} from '@ember/object';
import {service} from '@ember/service';
import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import GlobalState from 'accent-webapp/services/global-state';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import {dropTask} from 'ember-concurrency';
import IntlService from 'ember-intl/services/intl';
import Title from 'accent-webapp/components/project-settings/title/index';
import t from 'ember-intl/helpers/t';
import CheckSvg from 'accent-webapp/svgs/assets/check.svg';
import DeeplSvg from 'accent-webapp/svgs/assets/machine_translations_providers/deepl.svg';
import GoogleTranslateSvg from 'accent-webapp/svgs/assets/machine_translations_providers/google_translate.svg';
import {scopedClass} from 'ember-scoped-css';
import AccSelect from 'accent-webapp/components/acc-select/index';
import {fn} from '@ember/helper';
import {on} from '@ember/modifier';
import AsyncButton from 'accent-webapp/components/async-button/index';
import perform from 'ember-concurrency/helpers/perform';

interface Args {
  project: any;
  onDelete: () => Promise<void>;
  onSave: ({
    provider,
    enabledActions,
    usePlatform,
    configKey
  }: {
    provider: string;
    enabledActions: string[];
    usePlatform: boolean;
    configKey: string | null;
  }) => Promise<any>;
}

const PROVIDERS = ['google_translate', 'deepl'];

export default class ProjectSettingsMachineTranslations extends Component<Args> {
  <template>
    <div class='project-settings-form'>
      <Title
        @title={{t 'components.project_settings.machine_translations.title'}}
      />

      <p class='text'>
        {{t 'components.project_settings.machine_translations.text'}}
      </p>

      <div
        class='form
          {{if @project.machineTranslationsConfig "form--configured"}}'
      >
        <div class='provider'>
          {{#if this.isDeepl}}
            <DeeplSvg class={{scopedClass 'logo'}} />
          {{else if this.isGoogleTranslate}}
            <GoogleTranslateSvg class={{scopedClass 'logo'}} />
          {{/if}}

          <AccSelect
            @searchEnabled={{false}}
            @selected={{this.providerValue}}
            @renderInPlace={{true}}
            @options={{this.mappedProviders}}
            @onchange={{fn this.setProvider}}
            class='select'
          />

          {{#if @project.machineTranslationsConfig}}
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
            {{t
              'components.project_settings.machine_translations.use_platform_label'
            }}
          </label>

          <label class='option-checkbox'>
            <input
              value={{this.enabledActionsSync}}
              type='checkbox'
              checked={{this.enabledActionsSync}}
              {{on 'change' (fn this.onEnabledActionsChange 'sync')}}
            />
            {{t
              'components.project_settings.machine_translations.enabled_actions_sync'
            }}
          </label>
        </div>

        {{#unless this.usePlatform}}
          {{#if @project.machineTranslationsConfig.useConfigKey}}
            <p class='config-key-help'>
              {{t
                'components.project_settings.machine_translations.config_key_help_present'
              }}
            </p>
          {{else}}
            <p class='config-key-help'>
              {{t
                'components.project_settings.machine_translations.config_key_help_not_present'
              }}
            </p>
          {{/if}}

          <textarea
            placeholder={{this.configKeyPlaceholder}}
            rows={{if @project.machineTranslationsConfig.useConfigKey 1 8}}
            class='textInput'
            {{on 'change' (fn this.onConfigKeyChange)}}
          >{{this.configKey}}</textarea>
        {{/unless}}
      </div>

      <div class='actions'>
        {{#if @project.machineTranslationsConfig}}
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
      .project-settings-form {
        margin-top: 25px;
        max-width: 550px;
      }

      .form {
        margin-top: 25px;
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
        background: transparent;
        border: 1px solid var(--background-light-highlight);
        padding: 7px 10px;
        font-weight: bold;
        font-size: 13px;
      }

      .text {
        max-width: 490px;
        margin: 10px 0 15px;
        font-size: 13px;
        font-style: italic;
      }

      .logo {
        width: 25px;
      }

      .config-key-help {
        margin-top: 10px;
        font-size: 12px;
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
        margin-top: 20px;
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
  enabledActions =
    this.args.project.machineTranslationsConfig?.enabledActions || [];

  @tracked
  provider =
    this.args.project.machineTranslationsConfig?.provider || 'google_translate';

  @tracked
  usePlatform =
    this.args.project.machineTranslationsConfig?.usePlatform || false;

  @tracked
  configKey: any;

  get enabledActionsSync() {
    return this.enabledActions.includes('sync');
  }

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
        label: this.intl.t(`general.machine_translations_providers.${value}`),
        value
      };
    });
  }

  get configKeyPlaceholder() {
    if (this.args.project.machineTranslationsConfig?.useConfigKey) {
      return '••••••••••••••';
    } else {
      return this.intl.t(
        'components.project_settings.machine_translations.config_key_placeholder'
      );
    }
  }

  get isDeepl() {
    return this.provider === 'deepl';
  }

  get isGoogleTranslate() {
    return this.provider === 'google_translate';
  }

  @action
  setProvider({value}: {value: string}) {
    this.provider = value;
  }

  @action
  onEnabledActionsChange(action: string) {
    if (this.enabledActions.includes(action)) {
      this.enabledActions = this.enabledActions.filter(
        (enabledAction: string) => enabledAction !== action
      );
    } else {
      this.enabledActions = this.enabledActions.concat([action]);
    }
  }

  @action
  onUsePlatformChange(event: InputEvent) {
    const checked = (event.target as HTMLInputElement).checked;

    if (checked) this.configKey = null;
    this.usePlatform = checked;
  }

  @action
  onConfigKeyChange(event: InputEvent) {
    this.configKey = (event.target as HTMLInputElement).value;
  }

  submit = dropTask(async () => {
    await this.args.onSave({
      provider: this.provider,
      enabledActions: this.enabledActions,
      usePlatform: this.usePlatform,
      configKey: this.configKey
    });
  });

  remove = dropTask(async () => {
    await this.args.onDelete();
  });
}
