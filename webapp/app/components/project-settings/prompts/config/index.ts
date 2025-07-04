import {action} from '@ember/object';
import {service} from '@ember/service';
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
