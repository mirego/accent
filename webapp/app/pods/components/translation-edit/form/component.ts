import {inject as service} from '@ember/service';
import {equal} from '@ember/object/computed';
import {action} from '@ember/object';
import Component from '@glimmer/component';

import translationLintQuery from 'accent-webapp/queries/lint-translation';
import Apollo from 'accent-webapp/services/apollo';
import {tracked} from '@glimmer/tracking';
import {restartableTask} from 'ember-concurrency-decorators';
import {timeout} from 'ember-concurrency';

const DEBOUNCE_LINT_MESSAGES = 300;
const SMALL_INPUT_ROWS = 1;
const MEDIUM_INPUT_ROWS = 2;
const LARGE_INPUT_ROWS = 7;
const SMALL_INPUT_VALUE = 70;
const LARGE_INPUT_VALUE = 100;

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
  onKeyUp?: (text: string) => void;
}

export default class TranslationEditForm extends Component<Args> {
  @service('apollo')
  apollo: Apollo;

  @tracked
  lintMessages = this.args.lintMessages;

  @tracked
  showTypeHints = true;

  @tracked
  text = this.args.value;

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

  get rows() {
    if (!this.text) return SMALL_INPUT_ROWS;
    if (this.text.length < LARGE_INPUT_VALUE) return MEDIUM_INPUT_ROWS;
    if (this.text.length < SMALL_INPUT_VALUE) return SMALL_INPUT_ROWS;

    return LARGE_INPUT_ROWS;
  }

  get unusedPlaceholders() {
    return this.args.placeholders.reduce(
      (memo: Record<string, true>, placeholder: string) => {
        if (!this.text.includes(placeholder)) memo[placeholder] = true;
        return memo;
      },
      {}
    );
  }

  @action
  changeHTML(value: string) {
    const previousText = this.text;
    this.text = value;
    this.args.onKeyUp?.(value);

    if (previousText !== this.text) this.fetchLintMessages(value);
  }

  @action
  changeText(event: Event) {
    const target = event.target as HTMLInputElement;

    const previousText = this.text;
    this.text = target.value;
    this.args.onKeyUp?.(target.value);

    if (previousText !== this.text) this.fetchLintMessages(target.value);
  }

  @action
  didUpdateValue() {
    if (this.args.value) this.text = this.args.value;
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
    this.text = value;
    this.args.onKeyUp?.(value);
    this.fetchLintMessages(value);
  }

  fetchLintMessages(value: string) {
    // eslint-disable-next-line @typescript-eslint/ban-ts-ignore
    // @ts-ignore
    this.fetchLintMessagesTask.perform(value);
  }
}
