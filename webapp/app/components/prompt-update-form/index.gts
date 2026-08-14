import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import {action} from '@ember/object';
import didInsert from '@ember/render-modifiers/modifiers/did-insert';
import t from 'ember-intl/helpers/t';
import {on} from '@ember/modifier';
import {fn} from '@ember/helper';
import AccEmojiPicker from 'accent-webapp/components/acc-emoji-picker/index';
import PencilSvg from 'accent-webapp/svgs/assets/pencil.svg';
import XSvg from 'accent-webapp/svgs/assets/x.svg';
import {scopedClass} from 'ember-scoped-css';
import {LinkTo} from '@ember/routing';
import AsyncButton from 'accent-webapp/components/async-button/index';

interface Args {
  prompt: any;
  error: boolean;
  project: any;
  onUpdate: ({
    content,
    name,
    quickAccess
  }: {
    content: string;
    name: string;
    quickAccess: string;
  }) => Promise<void>;
}

export default class PromptUpdateForm extends Component<Args> {
  <template>
    <div class='prompt-update-form' {{didInsert this.focusTextarea}}>
      <h1 class='title'>
        {{t 'components.prompt_update_form.title'}}
      </h1>

      {{#if @error}}
        <div class='errors'>
          <div class='error'>
            {{t 'components.prompt_update_form.error'}}
          </div>
        </div>
      {{/if}}

      <div class='formItem'>
        <label class='formItem-label'>
          {{t 'components.prompt_update_form.name_label'}}
        </label>

        <div class='quickAccess-picker'>
          <input
            value={{this.name}}
            class='textInput'
            {{on 'keyup' (fn this.setName)}}
          />
          <AccEmojiPicker
            @onPicked={{fn this.setQuickAccess}}
            class='quickAccess-emoji'
          >
            {{#if this.quickAccess}}
              {{this.quickAccess}}
            {{else}}
              <PencilSvg class={{scopedClass 'quickAccess-picker-empty'}} />
            {{/if}}
          </AccEmojiPicker>
          {{#if this.quickAccess}}
            <button
              class='quickAccess-picker-remove'
              {{on 'click' this.clearQuickAccess}}
            >
              <XSvg class={{scopedClass 'quickAccess-picker-remove-icon'}} />
            </button>
          {{/if}}
        </div>
      </div>

      <div class='formItem'>
        <label class='formItem-label'>
          {{t 'components.prompt_update_form.content_label'}}
        </label>

        <textarea
          rows='8'
          class='textInput'
          {{on 'keyup' (fn this.setContent)}}
        >{{this.content}}</textarea>
      </div>

      <div class='formActions'>
        <LinkTo
          @route='logged-in.project.edit.prompts'
          @model={{@project.id}}
          class='button button--filled button--white'
        >
          {{t 'components.prompt_update_form.cancel_button'}}
        </LinkTo>

        <AsyncButton
          class='button button--filled'
          @loading={{this.isCreating}}
          @onClick={{fn this.submit}}
        >
          {{t 'components.prompt_update_form.save_button'}}
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
      .prompt-update-form {
        padding: 20px;
        background: var(--content-background);
      }

      .title {
        margin-bottom: 20px;
        text-align: center;
        font-size: 27px;
        font-weight: 300;
        color: var(--color-primary);
      }

      .text {
        font-size: 13px;
        margin-bottom: 20px;
        color: #555;
      }

      .quickAccess-picker {
        display: flex;
        position: relative;
        align-items: center;
      }

      .quickAccess-picker-empty {
        width: 23px;
        opacity: 0.7;
        color: var(--text-color-normal);
      }

      .quickAccess-picker-remove {
        width: 13px;
        height: 13px;
        background: transparent;
        position: absolute;
        right: -6px;
        top: 0;
        opacity: 0.5;
        padding: 0;
        color: var(--text-color-normal);
      }

      .quickAccess-picker-remove-icon {
        width: 13px;
        height: 13px;
      }

      .quickAccess-emoji {
        background: transparent;
        padding-left: 20px;
        font-size: 28px;
      }

      .textInput {
        flex-grow: 1;
        flex-shrink: 1;
        padding: 10px;
        min-width: 250px;
        width: 100%;
        font-size: 12px;
        font-family: var(--font-primary);
      }

      .errors {
        margin-bottom: 15px;
        padding-bottom: 5px;
      }

      .error {
        margin-bottom: 5px;
        color: var(--color-error);
        font-size: 13px;
        font-weight: bold;
      }

      .formItem {
        margin-bottom: 20px;
      }

      .formItem-label {
        display: block;
        margin-bottom: 8px;
        font-size: 13px;
      }

      .formActions {
        padding-top: 10px;
      }
    </style>
  </template>
  @tracked
  name = this.args.prompt.name;

  @tracked
  quickAccess = this.args.prompt.quickAccess;

  @tracked
  content = this.args.prompt.content;

  @tracked
  isSubmitting = false;

  @action
  async submit() {
    this.isSubmitting = true;

    const content = this.content;
    const quickAccess = this.quickAccess;
    const name = this.name;

    await this.args.onUpdate({content, name, quickAccess});

    if (!this.isDestroyed) this.isSubmitting = false;
  }

  @action
  setName(event: Event) {
    const target = event.target as HTMLInputElement;

    this.name = target.value;
  }

  @action
  setContent(event: Event) {
    const target = event.target as HTMLInputElement;

    this.content = target.value;
  }

  @action
  setQuickAccess(selection: string) {
    this.quickAccess = selection;
  }

  @action
  clearQuickAccess() {
    this.quickAccess = '';
  }

  @action
  focusTextarea(element: HTMLElement) {
    element.querySelector('input')?.focus();
  }
}
