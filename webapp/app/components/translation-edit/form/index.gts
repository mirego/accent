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
import inlineSvg from 'accent-webapp/helpers/inline-svg';
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
    | 'STRING'
    | 'HTML'
    | 'BOOLEAN'
    | 'INTEGER'
    | 'FLOAT'
    | 'EMPTY'
    | 'NULL';
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
            {{inlineSvg
              'assets/code.svg'
              class=(scopedClass 'placeholders-title-icon')
            }}
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
            {{inlineSvg
              'assets/bubble.svg'
              class=(scopedClass 'file-comment-title-icon')
            }}
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
              {{inlineSvg
                '/assets/loading.svg'
                class=(scopedClass 'lint-loading-icon')
              }}
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
