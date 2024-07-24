import {action} from '@ember/object';
import {empty} from '@ember/object/computed';
import Component from '@glimmer/component';
import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';
import {tracked} from '@glimmer/tracking';
import {MutationResponse} from 'accent-webapp/services/apollo-mutate';

interface Translation {
  id: string;
  key: string;
  conflictedText: string;
  correctedText: string;
  isConflicted: boolean;
  revision: {
    name: string | null;
    slug: string | null;
    rtl: boolean | null;
    isMaster: boolean;
    language: {
      name: string;
      slug: string;
      rtl: boolean;
    };
  };
}

interface Args {
  permissions: Record<string, true>;
  index: number;
  project: any;
  prompts: any[];
  translation: Translation;
  onFocus: () => void;
  onBlur: () => void;
  onCorrect: (translation: any, textInput: string) => Promise<MutationResponse>;
  onUpdate: (translation: any, textInput: string) => Promise<MutationResponse>;
  onUncorrect: (
    translation: any,
    textInput: string
  ) => Promise<MutationResponse>;
}

export default class ConflictsListItem extends Component<Args> {
  @empty('args.translation.conflictedText')
  emptyPreviousText: boolean;

  @tracked
  textInput = this.args.translation.correctedText;

  @tracked
  conflictResolved = false;

  @tracked
  isCorrectLoading = false;

  @tracked
  isUncorrectLoading = false;

  @tracked
  isUpdateLoading = false;

  @tracked
  error = false;

  @tracked
  inputDisabled = false;

  translationKey = parsedKeyProperty(this.args.translation.key);
  textOriginal = this.args.translation.correctedText;

  get showOriginalButton() {
    return this.textInput !== this.textOriginal;
  }

  get revisionTextDirRtl() {
    return this.args.translation.revision.rtl !== null
      ? this.args.translation.revision.rtl
      : this.args.translation.revision.language.rtl;
  }

  get revisionSlug() {
    return (
      this.args.translation.revision.slug ||
      this.args.translation.revision.language.slug
    );
  }

  @action
  changeTranslationText(text: string) {
    this.textInput = text;
  }

  @action
  setOriginalText() {
    this.textInput = this.textOriginal;
  }

  @action
  onUpdatingText() {
    this.inputDisabled = true;
  }

  @action
  onUpdateText(value: string) {
    this.textInput = value;
    this.inputDisabled = false;
  }

  @action
  async correctConflict() {
    this.onCorrectLoading();

    const response = await this.args.onCorrect(
      this.args.translation,
      this.textInput
    );

    if (response.errors) {
      this.onError();
    } else {
      this.onCorrectSuccess();
    }
  }

  @action
  async uncorrectConflict() {
    this.onUncorrectLoading();

    const response = await this.args.onUncorrect(
      this.args.translation,
      this.textInput
    );

    if (response.errors) {
      this.onError();
    } else {
      this.onUncorrectSuccess();
    }
  }

  @action
  async updateConflict() {
    this.onUpdateLoading();

    const response = await this.args.onUpdate(
      this.args.translation,
      this.textInput
    );

    if (response.errors) {
      this.onError();
    } else {
      this.onUpdateSuccess();
    }
  }

  private onCorrectLoading() {
    this.error = false;
    this.isCorrectLoading = true;
  }

  private onUncorrectLoading() {
    this.error = false;
    this.isUncorrectLoading = true;
  }

  private onUpdateLoading() {
    this.error = false;
    this.isUpdateLoading = true;
  }

  private onError() {
    this.error = true;
    this.isUpdateLoading = false;
    this.isCorrectLoading = false;
    this.isUncorrectLoading = false;
  }

  private onCorrectSuccess() {
    this.conflictResolved = true;
    this.isCorrectLoading = false;
  }

  private onUncorrectSuccess() {
    this.conflictResolved = false;
    this.isCorrectLoading = false;
  }

  private onUpdateSuccess() {
    this.isUpdateLoading = false;
  }
}
