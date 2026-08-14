import {service} from '@ember/service';
import {equal} from '@ember/object/computed';
import {next} from '@ember/runloop';
import {action} from '@ember/object';
import Component from '@glimmer/component';
import translationLintQuery from 'accent-webapp/queries/lint-translation';
import projectLintEntryCreateQuery from 'accent-webapp/queries/create-project-lint-entry';
import Apollo from 'accent-webapp/services/apollo';
import {tracked} from '@glimmer/tracking';
import {timeout, restartableTask} from 'ember-concurrency';
import MarkdownIt from 'markdown-it';
import {htmlSafe} from '@ember/template';
import didUpdate from '@ember/render-modifiers/modifiers/did-update';
import perform from 'ember-concurrency/helpers/perform';
import BubbleSvg from 'accent-webapp/svgs/assets/bubble.svg';
import CodeSvg from 'accent-webapp/svgs/assets/code.svg';
import LoadingSvg from 'accent-webapp/svgs/assets/loading.svg';
import {scopedClass} from 'ember-scoped-css';
import t from 'ember-intl/helpers/t';
import {get, fn, hash} from '@ember/helper';
import {on} from '@ember/modifier';
import HtmlTextarea from 'accent-webapp/components/html-textarea/index';
import TranslationEditFormSubmit from 'accent-webapp/components/translation-edit/form/submit/index';
import autoresize from 'ember-autoresize-modifier/modifiers/autoresize';
import onKey from 'ember-keyboard/modifiers/on-key';
import Item from 'accent-webapp/components/lint-translations-page/item/index';

const markdown = MarkdownIt({
  html: false,
  linkify: true,
  typographer: true
});

const DEBOUNCE_LINT_MESSAGES = 300;

interface Args {
  projectId: string;
  translationKey: string;
  translationId: string;
  lintMessages?: any[];
  inputDisabled: boolean;
  valueType:
    'STRING' | 'HTML' | 'BOOLEAN' | 'INTEGER' | 'FLOAT' | 'EMPTY' | 'NULL';
  value: string;
  originalValue?: string;
  onSubmit: () => void;
  showTypeHints?: boolean;
  placeholders?: any;
  onFocus?: () => void;
  onBlur?: () => void;
  onEscape?: () => void;
  onKeyUp?: (text: string) => void;
  fileComment?: string;
}

export default class TranslationEditForm extends Component<Args> {
  <template>
    <div
      class='translation-edit-form'
      {{didUpdate (perform this.onUpdateValue) @value}}
    >
      {{#if @placeholders}}
        <div class='placeholders'>
          <span class='placeholders-title'>
            <CodeSvg class={{scopedClass 'placeholders-title-icon'}} />
            {{t 'components.translation_edit.form.placeholders.title'}}
          </span>

          <div class='placeholders-text'>
            <p class='placeholders-text-content'>
              {{t 'components.translation_edit.form.placeholders.text'}}
            </p>
          </div>

          <ul>
            {{#each @placeholders as |placeholder|}}
              <li
                class='placeholders-item
                  {{if
                    (get this.unusedPlaceholders placeholder)
                    "placeholders-item--warning"
                  }}'
              >
                <code>
                  {{placeholder}}
                </code>
              </li>
            {{/each}}
          </ul>
        </div>
      {{/if}}

      {{#if this.showTypeHints}}
        {{#if this.isIntegerType}}
          <span class='label'>
            {{t 'components.translation_edit.form.integer_type_notice'}}
          </span>
        {{/if}}

        {{#if this.isFloatType}}
          <span class='label'>
            {{t 'components.translation_edit.form.float_type_notice'}}
          </span>
        {{/if}}

        {{#if this.isEmptyType}}
          <span class='label'>
            {{t 'components.translation_edit.form.empty_type_notice'}}
          </span>
        {{/if}}

        {{#if this.isNullType}}
          <span class='label'>
            {{t 'components.translation_edit.form.null_type_notice'}}
          </span>
        {{/if}}
      {{/if}}

      {{#if @fileComment}}
        <div class='file-comment'>
          <span class='file-comment-title'>
            <BubbleSvg class={{scopedClass 'file-comment-title-icon'}} />
            {{t 'components.translation_edit.form.file_comment.title'}}
          </span>

          <div class='file-comment-text'>
            <div class='file-comment-text-content'>{{this.fileComment}}</div>
          </div>
        </div>
      {{/if}}

      {{#if this.isBooleanType}}
        <div class='input-wrapper'>
          <span class='label'>
            {{t 'components.translation_edit.form.boolean_type_notice'}}
          </span>

          <div class='radio-wrapper'>
            <label class='radio-label'>
              <input
                type='radio'
                {{on 'change' (fn this.changeText)}}
                checked={{this.valueTrue}}
                name='value'
                value='true'
              />
              {{t 'components.translation_edit.form.true_option'}}
            </label>

            <label class='radio-label'>
              <input
                type='radio'
                {{on 'change' (fn this.changeText)}}
                checked={{this.valueFalse}}
                name='value'
                value='false'
              />
              {{t 'components.translation_edit.form.false_option'}}
            </label>
          </div>
        </div>
      {{else if this.isHTMLType}}
        <div class='input-wrapper'>
          <HtmlTextarea
            @value={{@value}}
            @onChange={{fn this.changeHTML}}
            @wysiwygOptions={{this.wysiwygOptions}}
          />

          {{yield
            (hash
              submit=(component TranslationEditFormSubmit)
              isTextUnchanged=this.isTextUnchanged
            )
          }}
        </div>
      {{else}}
        <div data-dir={{if @rtl 'rtl'}} class='input-wrapper'>
          <textarea
            disabled={{@inputDisabled}}
            value={{@value}}
            dir={{if @rtl 'rtl'}}
            ...attributes
            class='inputText {{if @borderless "inputText--borderless"}}'
            {{autoresize @value}}
            {{onKey 'Escape' (fn this.cancel)}}
            {{onKey 'cmd+Enter' (fn this.handleSubmit)}}
            {{on 'input' (fn this.changeText)}}
            {{on 'focus' (fn this.handleFocus)}}
            {{on 'blur' (fn this.handleBlur)}}
          ></textarea>
          {{! template-lint-disable "attribute-indentation" }}
          {{yield
            (hash
              dir=(if @rtl 'rtl')
              submit=(component TranslationEditFormSubmit)
              isTextUnchanged=this.isTextUnchanged
            )
          }}

          {{#if this.fetchLintMessagesTask.isRunning}}
            <div class='lint-loading'>
              <LoadingSvg class={{scopedClass 'lint-loading-icon'}} />
            </div>
          {{/if}}
        </div>
      {{/if}}

      <div
        class='lint-messages
          {{if this.fetchLintMessagesTask.isRunning "lint-messages--loading"}}'
      >
        <Item
          @permissions={{@permissions}}
          @lintTranslation={{this.lintTranslation}}
          @changeText={{fn @onKeyUp}}
          @createLintEntry={{unless
            this.fetchLintMessagesTask.isRunning
            (perform this.createLintEntryTask)
          }}
        />
      </div>
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
      .translation-edit-form {
        height: 100%;
      }
      .translation-edit-form :global(.ember-radio-button) {
        display: flex;
        align-items: center;
        padding: 10px;
        margin-bottom: 3px;
        border-radius: var(--border-radius);
        font-weight: bold;
        font-size: 13px;
        color: #444;
      }
      .translation-edit-form :global(.ember-radio-button).checked {
        background: var(--background-light-highlight);
        color: var(--text-color-normal);
      }
      .translation-edit-form :global(.ember-radio-button) :global(input) {
        margin-right: 8px;
      }

      .input-wrapper {
        position: relative;
      }

      .radio-wrapper {
        margin-top: 6px;
        font-size: 16px;
        font-weight: bold;
      }

      .radio-label {
        display: inline-flex;
        align-items: center;
        margin-right: 14px;
        font-family: var(--font-monospace);
      }
      .radio-label:global(> input) {
        margin-right: 5px;
      }

      .label {
        display: inline-block;
        padding: 5px 8px 4px;
        border-radius: var(--border-radius);
        margin-bottom: 5px;
        background: hsl(
          var(--color-blue-hue),
          var(--color-blue-saturation),
          var(--color-highlight-lighteness)
        );
        font-size: 11px;
        color: var(--color-blue);
      }

      .lint-loading {
        position: absolute;
        left: 0px;
        top: -22px;
        opacity: 0.5;
        font-size: 13px;
      }

      .lint-loading-icon {
        width: 10px;
      }

      .inputText {
        width: 100%;
        height: 100%;
        padding: 10px 130px 10px 10px;
        font-size: 13px;
      }
      .inputText[dir='rtl'] {
        padding: 10px 10px 10px 130px;
      }
      .inputText.inputText--borderless {
        border-color: transparent;
        background: transparent;
      }
      .inputText.inputText--borderless:focus {
        border-color: transparent;
        background: transparent;
      }
      .inputText::placeholder {
        opacity: 0.2;
        font-style: italic;
        font-family: var(--font-primary);
      }

      .placeholders {
        margin: 0 0 15px;
        padding: 15px;
        border-radius: var(--border-radius);
        font-size: 12px;
        background: hsl(
          var(--color-blue-hue),
          var(--color-blue-saturation),
          var(--color-highlight-lighteness)
        );
        color: var(--color-blue);
      }

      .placeholders-title {
        display: flex;
        align-items: center;
        margin-bottom: 3px;
        font-size: 13px;
        font-weight: bold;
      }

      .placeholders-text {
        margin-bottom: 6px;
      }

      .placeholders-text-content {
        max-width: 500px;
      }

      .placeholders-item {
        display: flex;
        align-items: center;
        font-size: 12px;
        color: var(--text-color-normal);
        opacity: 0.8;
        transition:
          color 0.2s ease-in-out,
          opacity 0.2s ease-in-out;
      }
      .placeholders-item.placeholders-item--warning {
        opacity: 1;
        color: var(--color-error);
      }

      .placeholders-item-icon {
        margin-right: 5px;
        width: 14px;
        height: 14px;
        stroke: var(--color-error);
      }

      .placeholders-title-icon {
        width: 14px;
        height: 14px;
        margin-right: 6px;
        stroke: var(--color-blue);
      }

      .file-comment {
        margin: 0 0 15px;
        padding: 15px 15px 5px;
        border-radius: var(--border-radius);
        font-size: 12px;
        background: var(--background-light);
        color: var(--color-black);
      }

      .file-comment-title {
        display: flex;
        align-items: center;
        margin-bottom: 3px;
        font-size: 13px;
        font-weight: bold;
      }

      .file-comment-text {
        margin-bottom: 6px;
      }

      .file-comment-text-content {
        max-width: 500px;
        font-family: var(--font-monospace);
      }

      .file-comment-title-icon {
        width: 14px;
        height: 14px;
        margin-right: 6px;
        stroke: var(--color-black);
      }

      .lint-messages {
        transition: 0.2s ease-in-out;
        transition-property: opacity;
      }

      .lint-messages--loading {
        opacity: 0.5;
      }

      @media (max-width: 640px) {
        .inputText {
          font-size: 16px;
        }
      }
    </style>
  </template>
  @service('apollo')
  declare apollo: Apollo;

  @tracked
  lintTranslation = {
    translation: {
      id: this.args.translationId,
      key: this.args.translationKey,
      text: this.args.value
    },
    messages: this.args.lintMessages
  };

  @tracked
  showTypeHints = true;

  @equal('args.value', 'true')
  valueTrue: boolean;

  @equal('args.value', 'false')
  valueFalse: boolean;

  @equal('args.valueType', 'STRING')
  isStringType: boolean;

  @equal('args.valueType', 'HTML')
  isHTMLType: boolean;

  @equal('args.valueType', 'BOOLEAN')
  isBooleanType: boolean;

  @equal('args.valueType', 'INTEGER')
  isIntegerType: boolean;

  @equal('args.valueType', 'FLOAT')
  isFloatType: boolean;

  @equal('args.valueType', 'EMPTY')
  isEmptyType: boolean;

  @equal('args.valueType', 'NULL')
  isNullType: boolean;

  wysiwygOptions = {};

  get isTextUnchanged() {
    if (this.args.originalValue === undefined) return false;
    return this.args.value === this.args.originalValue;
  }

  get fileComment() {
    if (!this.args.fileComment) return;

    return htmlSafe(markdown.render(this.args.fileComment));
  }

  get unusedPlaceholders() {
    return this.args.placeholders.reduce(
      (memo: Record<string, true>, placeholder: string) => {
        if (!this.args.value.includes(placeholder)) memo[placeholder] = true;
        return memo;
      },
      {}
    );
  }

  @action
  changeHTML(value: string) {
    this.args.onKeyUp?.(value);
  }

  @action
  handleFocus() {
    this.args.onFocus?.();
  }

  @action
  handleBlur() {
    next(this, () => this.args.onBlur?.());
  }

  @action
  handleSubmit() {
    this.args.onSubmit();
  }

  @action
  changeText(event: Event) {
    const target = event.target as HTMLInputElement;
    this.args.onKeyUp?.(target.value);
  }

  @action
  cancel() {
    this.args.onEscape?.();
  }

  onUpdateValue = restartableTask(
    async (_element: HTMLElement, [value]: string[]) => {
      await timeout(DEBOUNCE_LINT_MESSAGES);

      await this.fetchLintMessagesTask.perform(value);
    }
  );

  fetchLintMessagesTask = restartableTask(async (value: string) => {
    const {data} = await this.apollo.client.query<{
      viewer: {
        project: {
          translation: {
            lintMessages: any;
          };
        };
      };
    }>({
      fetchPolicy: 'network-only',
      query: translationLintQuery,
      variables: {
        text: value,
        projectId: this.args.projectId,
        translationId: this.args.translationId
      }
    });

    if (!data) return;

    this.lintTranslation = Object.assign(this.lintTranslation, {
      messages: data.viewer.project.translation.lintMessages
    });
  });

  createLintEntryTask = restartableTask(async (lintEntry: any) => {
    await this.apollo.client.mutate({
      mutation: projectLintEntryCreateQuery,
      refetchQueries: ['Translation'],
      variables: {
        projectId: this.args.projectId,
        checkIds: lintEntry.checkIds,
        type: lintEntry.type,
        value: lintEntry.value
      }
    });
  });

  @action
  replaceText(value: string) {
    this.args.onKeyUp?.(value);
  }
}
