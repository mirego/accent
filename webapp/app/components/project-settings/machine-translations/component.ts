import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import GlobalState from 'accent-webapp/services/global-state';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import {dropTask} from 'ember-concurrency';
import IntlService from 'ember-intl/services/intl';

interface Args {
  project: any;
  onDelete: () => Promise<void>;
  onSave: ({
    provider,
    enabledActions,
    usePlatform,
    configKey,
  }: {
    provider: string;
    enabledActions: string[];
    usePlatform: boolean;
    configKey: string | null;
  }) => Promise<any>;
}

const PROVIDERS = ['google_translate', 'deepl'];

/* eslint-disable camelcase */
const LOGOS = {
  deepl: 'assets/machine_translations_providers/deepl.svg',
  google_translate:
    'assets/machine_translations_providers/google_translate.svg',
};

export default class ProjectSettingsMachineTranslations extends Component<Args> {
  @service('global-state')
  globalState: GlobalState;

  @service('flash-messages')
  flashMessages: FlashMessages;

  @service('intl')
  intl: IntlService;

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
        value,
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

  get logoProvider() {
    const provider: keyof typeof LOGOS = this.provider;

    return LOGOS[provider];
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
      configKey: this.configKey,
    });
  });

  remove = dropTask(async () => {
    await this.args.onDelete();
  });
}
