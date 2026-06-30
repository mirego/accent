import {action} from '@ember/object';
import {empty} from '@ember/object/computed';
import Component from '@glimmer/component';
import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';
import {tracked} from '@glimmer/tracking';
import {MutationResponse} from 'accent-webapp/services/apollo-mutate';
import t from 'ember-intl/helpers/t';
import Form from 'accent-webapp/components/translation-edit/form/index';
import {fn, get} from '@ember/helper';
import AsyncButton from 'accent-webapp/components/async-button/index';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import Helpers from 'accent-webapp/components/translation-edit/helpers/index';

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
  <template>
    <li
      class='translation-item
        {{if @isFocused "focused"}}
        {{if this.error "errored"}}
        {{if this.conflictResolved "resolved"}}'
    >
      <div data-dir={{if this.revisionTextDirRtl 'rtl'}} class='item-details'>
        <div class='item-details__column'>
          {{#if this.error}}
            <div class='error'>
              {{t 'components.translation_item.correct_error_text'}}
            </div>
          {{/if}}
        </div>
        <div class='item-details__column'>
          <div class='textInput'>
            <Form
              @permissions={{@permissions}}
              @borderless={{true}}
              @projectId={{@project.id}}
              @translationId={{@translation.id}}
              @translationKey={{@translation.key}}
              @lintMessages={{@translation.lintMessages}}
              @valueType={{@translation.valueType}}
              @value={{this.textInput}}
              @originalValue={{this.textOriginal}}
              @inputDisabled={{this.inputDisabled}}
              @showTypeHints={{false}}
              @onKeyUp={{fn this.changeTranslationText}}
              @onSubmit={{this.onSubmitAction}}
              @onFocus={{@onFocus}}
              @onBlur={{@onBlur}}
              @rtl={{this.revisionTextDirRtl}}
              lang={{this.revisionSlug}}
              as |form|
            >
              <form.submit>
                <div data-dir={{form.dir}} class='button-submit'>
                  {{#if this.showOriginalButton}}
                    <AsyncButton
                      @onClick={{fn this.setOriginalText}}
                      class='button button--iconOnly button--white revert-button'
                    >
                      {{inlineSvg '/assets/revert.svg' class='button-icon'}}
                    </AsyncButton>
                  {{/if}}

                  <div class='form-helpers'>
                    <Helpers
                      @permissions={{@permissions}}
                      @project={{@project}}
                      @languageSlug={{this.revisionSlug}}
                      @prompts={{@prompts}}
                      @rtl={{this.revisionTextDirRtl}}
                      @text={{this.textInput}}
                      @onUpdatingText={{fn this.onUpdatingText}}
                      @onUpdateText={{fn this.onUpdateText}}
                    />
                  </div>

                  {{#if @translation.isConflicted}}
                    {{#if (get @permissions 'correctTranslation')}}
                      <AsyncButton
                        @loading={{this.isCorrectLoading}}
                        class='button button--iconOnly button--borderLess button--green'
                        @onClick={{fn this.correctConflict}}
                      >
                        {{inlineSvg '/assets/check.svg' class='button-icon'}}
                      </AsyncButton>
                    {{else if (get @permissions 'updateTranslation')}}
                      <AsyncButton
                        @loading={{this.isUpdateLoading}}
                        tabindex='-1'
                        class='button button--borderLess button--iconOnly button--grey'
                        @onClick={{fn this.updateConflict}}
                      >
                        {{inlineSvg '/assets/pencil.svg' class='button-icon'}}
                      </AsyncButton>
                    {{/if}}
                  {{else}}
                    {{#if (get @permissions 'uncorrectTranslation')}}
                      <AsyncButton
                        @loading={{this.isUncorrectLoading}}
                        class='button button--borderLess button--iconOnly button--red'
                        @onClick={{fn this.uncorrectConflict}}
                      >
                        {{inlineSvg '/assets/revert.svg' class='button-icon'}}
                      </AsyncButton>
                    {{else if (get @permissions 'updateTranslation')}}
                      <AsyncButton
                        @loading={{this.isUpdateLoading}}
                        tabindex='-1'
                        class='button button--borderLess button--iconOnly button--grey
                          {{if form.isTextUnchanged "button--unchanged"}}'
                        @onClick={{fn this.updateConflict}}
                      >
                        {{inlineSvg '/assets/pencil.svg' class='button-icon'}}
                      </AsyncButton>
                    {{/if}}
                  {{/if}}
                </div>
              </form.submit>
            </Form>
          </div>
        </div>
      </div>
    </li>
  </template>
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

  get onSubmitAction() {
    const {isConflicted} = this.args.translation;
    const {correctTranslation, uncorrectTranslation} = this.args.permissions;

    const action =
      (isConflicted && correctTranslation && this.correctConflict) ||
      (!isConflicted && uncorrectTranslation && this.uncorrectConflict) ||
      this.updateConflict;

    return action;
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
    this.isUncorrectLoading = false;
  }

  private onUncorrectSuccess() {
    this.conflictResolved = false;
    this.isCorrectLoading = false;
    this.isUncorrectLoading = false;
  }

  private onUpdateSuccess() {
    this.isUpdateLoading = false;
  }
}
