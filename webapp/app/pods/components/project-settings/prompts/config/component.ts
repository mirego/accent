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
    configKey,
  }: {
    provider: string;
    configKey: string | null;
  }) => Promise<any>;
}

const PROVIDERS = ['openai'];

/* eslint-disable camelcase */
const LOGOS = {
  openai: 'assets/prompts_providers/openai.svg',
};

export default class ProjectSettingsMachineTranslations extends Component<Args> {
  @service('global-state')
  globalState: GlobalState;

  @service('flash-messages')
  flashMessages: FlashMessages;

  @service('intl')
  intl: IntlService;

  @tracked
  provider = this.args.project.promptsConfig?.provider || 'openai';

  @tracked
  usePlatform = this.args.project.promptsConfig?.usePlatform || false;

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
        label: this.intl.t(`general.prompts_providers.${value}`),
        value,
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

  @dropTask
  *submit() {
    yield this.args.onSave({
      provider: this.provider,
      configKey: this.configKey,
    });
  }

  @dropTask
  *remove() {
    yield this.args.onDelete();
  }
}
