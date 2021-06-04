import {action} from '@ember/object';
import {empty} from '@ember/object/computed';
import Component from '@glimmer/component';
import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';
import {dropTask} from 'ember-concurrency-decorators';
import {tracked} from '@glimmer/tracking';
import {MutationResponse} from 'accent-webapp/services/apollo-mutate';
import {timeout} from 'ember-concurrency';

interface Args {
  permissions: Record<string, true>;
  index: number;
  project: any;
  conflict: any;
  onCorrect: (conflict: any, textInput: string) => Promise<MutationResponse>;
  onCopyTranslation: (
    text: string,
    sourceLanguageSlug: string,
    targetLanguageSlug: string
  ) => Promise<{text: string | null}>;
}

export default class ConflictItem extends Component<Args> {
  @empty('args.conflict.conflictedText')
  emptyPreviousText: boolean;

  @tracked
  textInput = this.args.conflict.correctedText;

  @tracked
  loading = false;

  @tracked
  error = false;

  @tracked
  resolved = false;

  @tracked
  show = false;

  conflictKey = parsedKeyProperty(this.args.conflict.key);
  textOriginal = this.args.conflict.correctedText;

  get showTextDiff() {
    if (!this.args.conflict.conflictedText) return false;

    return this.textInput !== this.args.conflict.conflictedText;
  }

  get showOriginalButton() {
    return this.textInput !== this.textOriginal;
  }

  get revisionName() {
    return (
      this.args.conflict.revision.name ||
      this.args.conflict.revision.language.name
    );
  }

  @dropTask
  *foo() {
    yield timeout(this.args.index * 100);

    this.show = true;
  }

  @action
  changeTranslationText(text: string) {
    this.textInput = text;
  }

  @action
  setOriginalText() {
    this.textInput = this.textOriginal;
  }

  @dropTask
  *copyTranslationTask(text: string, sourceLanguageSlug: string) {
    const copyTranslation = yield this.args.onCopyTranslation(
      text,
      sourceLanguageSlug,
      this.revisionSlug
    );

    if (copyTranslation.text) {
      this.textInput = copyTranslation.text;
    }
  }

  @action
  async correct() {
    this.onLoading();

    const response = await this.args.onCorrect(
      this.args.conflict,
      this.textInput
    );

    if (response.errors) {
      this.onError();
    } else {
      this.onCorrectSuccess();
    }
  }

  private onLoading() {
    this.error = false;
    this.loading = true;
  }

  private onError() {
    this.error = true;
    this.loading = false;
  }

  private onCorrectSuccess() {
    this.resolved = true;
    this.loading = false;
  }

  private get revisionSlug() {
    return (
      this.args.conflict.revision.slug ||
      this.args.conflict.revision.language.slug
    );
  }
}
