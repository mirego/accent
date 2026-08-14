import Component from '@glimmer/component';
import {action} from '@ember/object';
import {tracked} from '@glimmer/tracking';
import {timeout, dropTask} from 'ember-concurrency';
import {MutationResponse} from 'accent-webapp/services/apollo-mutate';
import {on} from '@ember/modifier';
import perform from 'ember-concurrency/helpers/perform';
import t from 'ember-intl/helpers/t';
import autoresize from 'ember-autoresize-modifier/modifiers/autoresize';
import onKey from 'ember-keyboard/modifiers/on-key';
import AsyncButton from 'accent-webapp/components/async-button/index';

interface Args {
  value?: string;
  onSubmit: (text: string) => Promise<MutationResponse>;
}

const SUBMIT_DEBOUNCE = 1000;

export default class TranslationCommentForm extends Component<Args> {
  <template>
    <div class='translation-comment-form'>
      <form class='form' {{on 'submit' (perform this.submitTask)}}>
        {{#if this.error}}
          <span class='error'>
            {{t 'components.translation_comment_form.submit_error'}}
          </span>
        {{/if}}

        <div class='form-content'>
          <textarea
            placeholder={{t
              'components.translation_comment_form.comment_placeholder'
            }}
            rows='1'
            disabled={{this.isSubmitting}}
            value={{this.text}}
            class='inputText'
            {{autoresize this.text}}
            {{onKey 'cmd+Enter' (perform this.submitTask)}}
            {{on 'input' this.setText}}
          ></textarea>
          <AsyncButton
            @loading={{this.isSubmitting}}
            class='button button--filled'
            {{on 'click' (perform this.submitTask)}}
          >
            {{t 'components.translation_comment_form.comment_button'}}
          </AsyncButton>
        </div>
      </form>
    </div>

    <style scoped>
      .inputText {
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
      .inputText::-moz-selection {
        background: color-mix(in srgb, var(--color-primary) 70%, transparent);
      }
      .inputText::selection {
        background: color-mix(in srgb, var(--color-primary) 70%, transparent);
      }
      .inputText:focus {
        border: 2px solid var(--color-primary);
      }
      .inputText:disabled {
        color: var(--color-grey);
        background: var(--background-light);
      }

      @media (hover: none) and (max-width: 640px) {
        .inputText {
          font-size: 16px !important;
        }
      }
      .form-content {
        display: flex;
        align-items: flex-start;
      }
      .form-content .label {
        padding: 9px 12px 10px;
      }

      .error {
        display: block;
        margin-bottom: 10px;
        color: var(--color-error);
        font-size: 13px;
        font-weight: bold;
      }

      .inputText {
        flex-grow: 1;
        padding: 10px;
        margin-right: 10px;
        width: 100%;
        font-family: var(--font-primary);
        font-size: 13px;
      }

      @media (max-width: 440px) {
        .form-content {
          flex-direction: column;
        }
        .inputText {
          margin-bottom: 10px;
        }
      }
    </style>
  </template>
  @tracked
  text = this.args.value || '';

  @tracked
  error = false;

  get isSubmitting() {
    return this.submitTask.isRunning;
  }

  submitTask = dropTask(async (event?: Event) => {
    this.error = false;
    event?.preventDefault();

    await timeout(SUBMIT_DEBOUNCE);
    const response = await this.args.onSubmit(this.text);

    if (response.errors) {
      this.error = true;
    } else {
      this.text = '';
    }
  });

  @action
  setText(event: KeyboardEvent) {
    const target = event.target as HTMLInputElement;
    this.text = target.value;
  }
}
