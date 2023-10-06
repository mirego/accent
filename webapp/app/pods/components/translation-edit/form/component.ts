import {inject as service} from '@ember/service';
import {equal} from '@ember/object/computed';
import {action} from '@ember/object';
import Component from '@glimmer/component';

import translationLintQuery from 'accent-webapp/queries/lint-translation';
import Apollo from 'accent-webapp/services/apollo';
import {tracked} from '@glimmer/tracking';
import {restartableTask} from 'ember-concurrency-decorators';
import {perform} from 'ember-concurrency-ts';
import {timeout, TaskGenerator} from 'ember-concurrency';
import MarkdownIt from 'markdown-it';
import {htmlSafe} from '@ember/template';

const markdown = MarkdownIt({
  html: false,
  linkify: true,
  typographer: true,
});

const DEBOUNCE_LINT_MESSAGES = 800;

interface Args {
  projectId: string;
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
  @service('apollo')
  apollo: Apollo;

  @tracked
  lintTranslation = {
    translation: {id: this.args.translationId, text: this.args.value},
    messages: this.args.lintMessages,
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
  changeText(event: Event) {
    const target = event.target as HTMLInputElement;
    this.args.onKeyUp?.(target.value);
  }

  @action
  cancel() {
    this.args.onEscape?.();
  }

  @restartableTask
  *onUpdateValue(
    _element: HTMLElement,
    [value]: string[]
  ): TaskGenerator<void> {
    yield timeout(DEBOUNCE_LINT_MESSAGES);

    yield perform(this.fetchLintMessagesTask, value);
  }

  @restartableTask
  *fetchLintMessagesTask(value: string) {
    const {data} = yield this.apollo.client.query({
      fetchPolicy: 'network-only',
      query: translationLintQuery,
      variables: {
        text: value,
        projectId: this.args.projectId,
        translationId: this.args.translationId,
      },
    });

    this.lintTranslation = Object.assign(this.lintTranslation, {
      messages: data.viewer.project.translation.lintMessages,
    });
  }

  @action
  replaceText(value: string) {
    this.args.onKeyUp?.(value);
  }
}
