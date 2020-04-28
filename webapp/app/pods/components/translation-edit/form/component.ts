import {inject as service} from '@ember/service';
import {equal} from '@ember/object/computed';
import {action} from '@ember/object';
import Component from '@glimmer/component';

import translationLintQuery from 'accent-webapp/queries/lint-translation';
import Apollo from 'accent-webapp/services/apollo';
import {tracked} from '@glimmer/tracking';
import {restartableTask} from 'ember-concurrency-decorators';
import {timeout} from 'ember-concurrency';

const DEBOUNCE_LINT_MESSAGES = 1000;
const SMALL_INPUT_ROWS = 1;
const MEDIUM_INPUT_ROWS = 3;
const LARGE_INPUT_ROWS = 7;
const SMALL_INPUT_VALUE = 70;
const LARGE_INPUT_VALUE = 100;

interface Context {
  text: string;
  offset: number;
  length: number;
}

interface Args {
  projectId: string;
  translationId: string;
  disabled: boolean;
  valueType: 'STRING' | 'BOOLEAN' | 'INTEGER' | 'FLOAT' | 'EMPTY' | 'NULL';
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
  lintMessages: String[] = [];

  @tracked
  showTypeHints = true;

  @tracked
  text = this.args.value;

  @equal('args.valueType', 'STRING')
  isStringType: boolean;

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
  initialLint() {
    this.fetchLintMessages(this.text);
  }

  @action
  changeText(event: Event) {
    const target = event.target as HTMLInputElement;

    this.text = target.value;
    this.args.onKeyUp?.(target.value);
    this.fetchLintMessages(target.value);
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

    this.lintMessages = data.viewer.project.translation
      .lintMessages as String[];
  }

  @action
  replaceText(context: Context, replacement: any) {
    const wordToReplace = context.text.substring(
      context.offset,
      context.offset + context.length
    );

    const newText = this.text.replace(wordToReplace, replacement.value);

    this.text = newText;
    this.args.onKeyUp?.(newText);
    this.fetchLintMessages(newText);
  }

  fetchLintMessages(value: string) {
    // eslint-disable-next-line @typescript-eslint/ban-ts-ignore
    // @ts-ignore
    this.fetchLintMessagesTask.perform(value);
  }
}
