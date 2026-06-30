import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import {action} from '@ember/object';
import didInsert from '@ember/render-modifiers/modifiers/did-insert';
import t from 'ember-intl/helpers/t';
import {on} from '@ember/modifier';
import {fn} from '@ember/helper';
import AccEmojiPicker from 'accent-webapp/components/acc-emoji-picker/index';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
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
              {{inlineSvg
                'assets/pencil.svg'
                class=(scopedClass 'quickAccess-picker-empty')
              }}
            {{/if}}
          </AccEmojiPicker>
          {{#if this.quickAccess}}
            <button
              class='quickAccess-picker-remove'
              {{on 'click' this.clearQuickAccess}}
            >
              {{inlineSvg
                'assets/x.svg'
                class=(scopedClass 'quickAccess-picker-remove-icon')
              }}
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
