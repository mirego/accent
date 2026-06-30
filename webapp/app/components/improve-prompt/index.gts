import Component from '@glimmer/component';
import {service} from '@ember/service';
import {action} from '@ember/object';
import {tracked} from '@glimmer/tracking';
import {dropTask} from 'ember-concurrency';
import Apollo from 'accent-webapp/services/apollo';
import improveTextPromptMutation from 'accent-webapp/queries/improve-text-prompt';
import projectPrompts from 'accent-webapp/queries/project-prompts';
import {IntlService} from 'ember-intl';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import AsyncButton from 'accent-webapp/components/async-button/index';
import perform from 'ember-concurrency/helpers/perform';
import {on} from '@ember/modifier';
import {fn} from '@ember/helper';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import AccModal from 'accent-webapp/components/acc-modal/index';
import didInsert from '@ember/render-modifiers/modifiers/did-insert';
import {scopedClass} from 'ember-scoped-css';
import t from 'ember-intl/helpers/t';
import AccSelect from 'accent-webapp/components/acc-select/index';

const FLASH_MESSAGE_PREFIX = 'components.improve_prompt.flash_messages.';
const FLASH_MESSAGE_PROMPT_IMPROVE_ERROR = `${FLASH_MESSAGE_PREFIX}improve_error`;

interface Args {
  text: string;
  project: {id: string};
  prompts: any[];
  onUpdatingText: () => void;
  onUpdateText: (value: string) => void;
}

interface Prompt {
  id: string;
  name: string;
}

interface PromptOption {
  label: string;
  value: string;
}

interface ProjectPromptsData {
  viewer: {
    project: {
      prompts: Prompt[];
    };
  };
}

interface ImproveTextPromptData {
  improveTextWithPrompt?: {
    text?: string;
    errors?: string[];
  };
}

export default class ImprovePrompt extends Component<Args> {
  <template>
    {{#if @prompts}}
      <div tabindex='0' class='prompt-button'>
        <div data-rtl={{@rtl}} class='prompt-button-quick-access'>
          {{#each this.quickAccessPrompts as |prompt|}}
            <AsyncButton
              title={{prompt.name}}
              @onClick={{perform this.submitTask prompt.id}}
              class='button button--iconOnly button--filled button--borderless button--white prompt-button-quick-access-icon'
            >
              {{prompt.quickAccess}}
            </AsyncButton>
          {{/each}}
        </div>

        <button
          {{on 'click' (fn this.onPromptClick)}}
          class='button button--iconOnly button--link button--filled button--white local-button'
        >
          {{inlineSvg '/assets/sparkle.svg' class='button-icon'}}
        </button>
      </div>
    {{/if}}

    {{#if this.promptOpened}}
      <AccModal @onClose={{fn this.onPromptClose}}>
        <div class='content' {{didInsert (perform this.fetchPromptOptions)}}>
          <div class='title'>
            {{inlineSvg 'assets/sparkle.svg' class=(scopedClass 'title-icon')}}
            {{t 'components.improve_prompt.title'}}
          </div>

          <div class='current-text'>{{@text}}</div>

          {{#if this.promptOptions}}
            <AccSelect
              @selected={{this.promptOptionValue}}
              @options={{this.promptOptions}}
              @onchange={{fn this.onSelectPromptOption}}
            />
          {{/if}}

          {{#if this.promptResult}}
            {{#if this.promptResultUnchanged}}
              <div class='result-text result-text--unchanged'>{{t
                  'components.improve_prompt.no_changes'
                }}</div>
            {{else}}
              <div class='result-text'>{{this.promptResult}}</div>
            {{/if}}
          {{/if}}

          <div class='actions'>
            <AsyncButton
              @onClick={{perform this.submitTask}}
              @loading={{this.isSubmitting}}
              class='button button--filled button--white'
            >
              {{t 'components.improve_prompt.run'}}
            </AsyncButton>

            {{#if this.promptResult}}
              {{#unless this.promptResultUnchanged}}
                <button
                  {{on 'click' (fn this.onAcceptText)}}
                  class='button button--filled'
                >
                  {{t 'components.improve_prompt.accept'}}
                </button>
              {{/unless}}
            {{/if}}
          </div>
        </div>
      </AccModal>
    {{/if}}
  </template>
  @service('apollo')
  declare apollo: Apollo;

  @service('intl')
  declare intl: IntlService;

  @service('flash-messages')
  declare flashMessages: FlashMessages;

  @tracked
  promptOptions: PromptOption[] = [];

  @tracked
  promptOptionValue: PromptOption | null;

  @tracked
  promptResult: string | null;

  @tracked
  promptResultUnchanged = true;

  @tracked
  promptOpened = false;

  get isSubmitting() {
    return this.submitTask.isRunning;
  }

  @action
  onSelectPromptOption(option: PromptOption) {
    this.promptOptionValue = option;
  }

  get quickAccessPrompts() {
    return this.args.prompts.filter((prompt) => prompt.quickAccess);
  }

  @action
  onAcceptText() {
    if (!this.promptResult) return;

    this.args.onUpdateText(this.promptResult);
    this.promptOpened = false;
  }

  fetchPromptOptions = dropTask(async () => {
    const variables = {projectId: this.args.project.id};
    const {data} = await this.apollo.client.query<ProjectPromptsData>({
      query: projectPrompts,
      fetchPolicy: 'network-only',
      variables
    });

    if (!data?.viewer.project.prompts) return;

    this.promptOptions = data.viewer.project.prompts.map((prompt: Prompt) => ({
      label: prompt.name,
      value: prompt.id
    }));
    this.promptOptionValue = this.promptOptions[0];
  });

  @action
  onPromptClose() {
    this.args.onUpdateText(this.args.text);
    this.promptOpened = false;
  }

  @action
  onPromptClick() {
    this.promptOpened = true;
  }

  submitTask = dropTask(async (promptId?: string) => {
    if (!promptId && !this.promptOptionValue) return;
    if (!this.promptOpened) this.args.onUpdatingText();

    this.promptResult = null;
    this.promptResultUnchanged = true;

    const variables = {
      text: this.args.text,
      promptId: promptId || this.promptOptionValue?.value
    };
    const {data} = await this.apollo.client.mutate<ImproveTextPromptData>({
      mutation: improveTextPromptMutation,
      variables
    });

    if (data?.improveTextWithPrompt?.text) {
      if (this.promptOpened) {
        this.promptResult = data.improveTextWithPrompt.text;
        this.promptResultUnchanged = this.promptResult === this.args.text;
      } else {
        this.args.onUpdateText(data.improveTextWithPrompt.text);
      }
    } else if (data?.improveTextWithPrompt?.errors) {
      this.args.onUpdateText(this.args.text);
      this.flashMessages.error(this.intl.t(FLASH_MESSAGE_PROMPT_IMPROVE_ERROR));
    }
  });
}
