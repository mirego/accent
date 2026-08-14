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
import SparkleSvg from 'accent-webapp/svgs/assets/sparkle.svg';
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
          <SparkleSvg class='button-icon' />
        </button>
      </div>
    {{/if}}

    {{#if this.promptOpened}}
      <AccModal @onClose={{fn this.onPromptClose}}>
        <div class='content' {{didInsert (perform this.fetchPromptOptions)}}>
          <div class='title'>
            <SparkleSvg class={{scopedClass 'title-icon'}} />
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

    <style scoped>
      .content {
        padding: 20px;
      }
      .content :global(.ember-power-select-trigger) {
        min-height: 31px;
        margin-bottom: 10px;
        background: var(--content-background);
        border: 1px solid var(--background-light-highlight);
      }

      .actions {
        display: flex;
        justify-content: flex-end;
        margin-top: 20px;
        gap: 10px;
      }

      button.local-button {
        padding-left: 10px;
        padding-right: 10px;
        border-radius: var(--border-radius);
      }
      button.local-button:focus,
      button.local-button:hover {
        transform: translate3d(0, 0, 0);
      }

      .current-text {
        white-space: pre-line;
        font-size: 13px;
        opacity: 0.5;
        padding: 5px 0;
        margin-bottom: 6px;
      }

      .result-error {
        white-space: pre-line;
        font-size: 11px;
        color: var(--color-error);
        padding: 7px 0;
        margin-top: 5px;
      }

      .result-text {
        white-space: pre-line;
        font-size: 13px;
        margin-top: 10px;
      }

      .result-text--unchanged {
        font-style: italic;
        font-size: 11px;
        opacity: 0.5;
      }

      .prompt-button {
        position: relative;
        display: flex;
        align-items: center;
      }
      .prompt-button > .local-button {
        transition: opacity 0.2s ease-in-out;
        box-shadow: none;
        opacity: 0.7;
      }
      .prompt-button:focus,
      .prompt-button:hover {
        outline: none;
      }
      .prompt-button:focus > .local-button,
      .prompt-button:hover > .local-button {
        opacity: 1;
      }
      .prompt-button:focus .prompt-button-quick-access[data-rtl],
      .prompt-button:hover .prompt-button-quick-access[data-rtl] {
        transform: translateX(36px);
        right: auto;
      }
      .prompt-button:focus .prompt-button-quick-access,
      .prompt-button:hover .prompt-button-quick-access {
        opacity: 1;
        transform: translateX(-20px);
        padding: 0 7px;
        top: -1px;
        pointer-events: all;
      }

      .prompt-button-quick-access[data-rtl] {
        left: 0;
        right: auto;
      }

      .prompt-button-quick-access-icon {
        box-shadow: none;
      }

      .prompt-button-quick-access-icon :global(.label) {
        padding: 3px !important;
      }

      .prompt-button-quick-access {
        background: var(--input-background);
        opacity: 0;
        pointer-events: none;
        transform: translateX(0);
        right: 0;
        display: flex;
        gap: 4px;
        align-items: center;
        position: absolute;
        top: 0;
        transition: all 0.2s ease-in-out;
      }
      .prompt-button-quick-access > button:focus,
      .prompt-button-quick-access > button:hover {
        transform: translate3d(0, 0, 0);
      }
      .prompt-button-quick-access > button :global(.label) {
        padding-left: 8px;
        padding-right: 8px;
      }

      .title {
        display: flex;
        gap: 10px;
        align-items: center;
        margin-bottom: 10px;
        text-align: center;
        font-size: 17px;
        color: var(--color-primary);
      }

      .title-icon {
        width: 15px;
        opacity: 0.8;
      }
    </style>
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
