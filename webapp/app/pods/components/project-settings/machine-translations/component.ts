import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import GlobalState from 'accent-webapp/services/global-state';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import {dropTask} from 'ember-concurrency-decorators';
import {taskFor} from 'ember-concurrency-ts';
import IntlService from 'ember-intl/services/intl';

interface Args {
  project: any;
  onDelete: () => void;
  onSave: ({
    provider,
    usePlatform,
    configKey,
  }: {
    provider: string;
    usePlatform: boolean;
    configKey: string | null;
  }) => Promise<any>;
}

const PROVIDERS = ['google_translate', 'deepl'];

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
  provider =
    this.args.project.machineTranslationsConfig?.provider || 'google_translate';

  @tracked
  usePlatform =
    this.args.project.machineTranslationsConfig?.usePlatform || false;

  @tracked
  configKey: any;

  get providerValue() {
    return this.mappedProviders.find(({value}) => value === this.provider);
  }

  get isSubmitting() {
    return taskFor(this.submit).isRunning;
  }

  get isRemoving() {
    return taskFor(this.remove).isRunning;
  }

  get mappedProviders() {
    return PROVIDERS.map((value) => {
      return {
        label: this.intl.t(`general.machine_translations_providers.${value}`),
        value,
      };
    });
  }

  get logoProvider() {
    const provider: keyof typeof LOGOS = this.provider as any;

    return LOGOS[provider];
  }

  @action
  setProvider({value}: {value: string}) {
    this.provider = value;
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

  @dropTask
  *submit() {
    yield this.args.onSave({
      provider: this.provider,
      usePlatform: this.usePlatform,
      configKey: this.configKey,
    });
  }

  @dropTask
  *remove() {
    yield this.args.onDelete();
  }
}
