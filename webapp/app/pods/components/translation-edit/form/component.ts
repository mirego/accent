import {inject as service} from '@ember/service';
import {equal} from '@ember/object/computed';
import {action} from '@ember/object';
import Component from '@glimmer/component';

import translationLintQuery from 'accent-webapp/queries/lint-translation';
import Apollo from 'accent-webapp/services/apollo';
import {tracked} from '@glimmer/tracking';
import {restartableTask} from 'ember-concurrency-decorators';
import {timeout} from 'ember-concurrency';
import {Task} from 'accent-webapp/types/task';

const DEBOUNCE_LINT_MESSAGES = 1000;

interface Args {
  projectId: string;
  translationId: string;
  lintMessages?: any[];
  disabled: boolean;
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
}

export default class TranslationEditForm extends Component<Args> {
  @service('apollo')
  apollo: Apollo;

  @tracked
  lintMessages = this.args.lintMessages;

  @tracked
  showTypeHints = true;

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
    const previousText = this.args.value;
    this.args.onKeyUp?.(value);

    if (previousText !== value)
      (this.fetchLintMessagesTask as Task).perform(value);
  }

  @action
  cancel() {
    this.args.onEscape?.();
  }

  @action
  changeText(event: Event) {
    const target = event.target as HTMLInputElement;
    const previousText = this.args.value;
    this.args.onKeyUp?.(target.value);

    if (previousText !== target.value)
      (this.fetchLintMessagesTask as Task).perform(target.value);
  }

  @restartableTask
  *fetchLintMessagesTask(value: string) {
    yield timeout(DEBOUNCE_LINT_MESSAGES);

    const {data} = yield this.apollo.client.query({
      fetchPolicy: 'network-only',
      query: translationLintQuery,
      variables: {
        text: value,
        projectId: this.args.projectId,
        translationId: this.args.translationId,
      },
    });

    this.lintMessages = data.viewer.project.translation.lintMessages;
  }

  @action
  replaceText(value: string) {
    this.args.onKeyUp?.(value);
    (this.fetchLintMessagesTask as Task).perform(value);
  }
}
