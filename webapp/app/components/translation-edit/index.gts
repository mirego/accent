import {action} from '@ember/object';
import {next} from '@ember/runloop';
import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import didUpdate from '@ember/render-modifiers/modifiers/did-update';
import didInsert from '@ember/render-modifiers/modifiers/did-insert';
import Form from 'accent-webapp/components/translation-edit/form/index';
import {fn, array, get} from '@ember/helper';
import Helpers from 'accent-webapp/components/translation-edit/helpers/index';
import {LinkTo} from '@ember/routing';
import t from 'ember-intl/helpers/t';
import AsyncButton from 'accent-webapp/components/async-button/index';
import CheckSvg from 'accent-webapp/svgs/assets/check.svg';
import RevertSvg from 'accent-webapp/svgs/assets/revert.svg';

interface Args {
  translation: any;
  text: string | null;
  project: any;
  permissions: Record<string, true>;
  onChangeText?: (text: string) => void;
  onUpdateText: (text: string) => Promise<void>;
  onCorrectConflict: (text: string) => Promise<void>;
  onUncorrectConflict: (text: string) => Promise<void>;
}

export default class TranslationEdit extends Component<Args> {
  <template>
    <div
      class='translation-edit'
      {{didUpdate this.didUpdateCorrectedText @translation.correctedText}}
    >
      {{#if @translation.id}}
        <div class='form' {{didInsert this.focusTextarea}}>
          <Form
            @permissions={{@permissions}}
            @projectId={{@project.id}}
            @translationId={{@translation.id}}
            @translationKey={{@translation.key}}
            @fileComment={{@translation.fileComment}}
            @lintMessages={{@translation.lintMessages}}
            @placeholders={{@translation.masterTranslation.placeholders}}
            @inputDisabled={{this.inputDisabled}}
            @valueType={{@translation.valueType}}
            @value={{this.text}}
            @onKeyUp={{fn this.changeText}}
            @onSubmit={{fn this.updateText}}
            @rtl={{this.revisionTextDirRtl}}
            lang={{this.revisionSlug}}
            class='jipt'
          />

          {{#unless @translation.isRemoved}}
            <div data-rtl={{this.revisionTextDirRtl}} class='form-improve'>
              <Helpers
                @permissions={{@permissions}}
                @languageSlug={{this.revisionSlug}}
                @project={{@project}}
                @prompts={{@prompts}}
                @rtl={{this.revisionTextDirRtl}}
                @text={{this.text}}
                @onUpdatingText={{fn this.onUpdatingText}}
                @onUpdateText={{fn this.onUpdateText}}
              />
            </div>
          {{/unless}}
        </div>
      {{/if}}

      {{#if @translation}}
        {{#unless @translation.isRemoved}}
          <div class='actions'>
            <div class='actions-links'>
              {{#if @translation.sourceTranslation}}
                {{#if @translation.version}}
                  <LinkTo
                    @route='logged-in.project.translation'
                    @models={{array
                      @project.id
                      @translation.sourceTranslation.id
                    }}
                    class='actions-link'
                  >
                    {{t 'components.translation_edit.source_translation'}}
                  </LinkTo>
                {{/if}}
              {{/if}}
            </div>

            <div class='actions-buttons'>
              {{#unless this.hasTextNotChanged}}
                <AsyncButton
                  @onClick={{fn this.setOriginalText}}
                  class='button button--iconOnly button--white actions-button-revert'
                >
                  <RevertSvg class='button-icon' />
                </AsyncButton>
              {{/unless}}

              {{#if (get @permissions 'updateTranslation')}}
                <AsyncButton
                  @loading={{this.isUpdatingText}}
                  class='button button--filled button--white'
                  @onClick={{fn this.updateText}}
                >
                  {{t 'components.translation_edit.update_text'}}
                </AsyncButton>
              {{/if}}
              {{#if @translation.isConflicted}}
                {{#if (get @permissions 'correctTranslation')}}
                  <AsyncButton
                    @loading={{this.isCorrectingConflict}}
                    class='button button--filled'
                    @onClick={{fn this.correctConflict}}
                  >
                    <CheckSvg class='button-icon' />
                    {{t 'components.translation_edit.correct_button'}}
                  </AsyncButton>
                {{/if}}
              {{else}}

                {{#if (get @permissions 'uncorrectTranslation')}}
                  <AsyncButton
                    @loading={{this.isUncorrectingConflict}}
                    class='button button--filled button--red'
                    @onClick={{fn this.uncorrectConflict}}
                  >
                    <RevertSvg class='button-icon' />
                    {{t 'components.translation_edit.uncorrect_button'}}
                  </AsyncButton>
                {{/if}}
              {{/if}}
            </div>
          </div>
        {{/unless}}
      {{/if}}
    </div>

    <style scoped>
      .translation-edit {
        width: 100%;
      }

      .jipt {
        padding-right: 15px;
        padding-left: 15px;
      }

      .previousText {
        margin-bottom: 15px;
        color: var(--color-grey);
        font-size: 12px;
      }

      .previousText-label {
        color: var(--color-gray);
        font-weight: bold;
      }

      .previousText-empty {
        font-style: italic;
      }

      .previousText-text {
        white-space: pre-wrap;
        font-size: 11px;
      }

      .actions {
        display: flex;
        justify-content: space-between;
        align-items: center;
        width: 100%;
        margin-top: 15px;
      }

      .form {
        position: relative;
      }

      .form-improve[data-rtl] {
        left: 6px;
        right: auto;
      }

      .form-improve {
        position: absolute;
        right: 6px;
        top: 6px;
      }

      .actions-link {
        display: flex;
        align-items: center;
        font-size: 13px;
        font-weight: bold;
        text-decoration: none;
        color: var(--color-primary);
        transition: 0.2s ease-in-out;
        transition-property: color, opacity;
      }
      .actions-link:focus,
      .actions-link:hover {
        opacity: 0.7;
      }

      .actions-link-icon {
        width: 18px;
        height: 18px;
        margin-right: 3px;
        stroke: var(--color-primary);
        transition: 0.2s ease-in-out;
        transition-property: stroke;
      }

      .actions-buttons {
        display: flex;
        justify-content: flex-end;
        align-items: center;
      }
      .actions-buttons > :global(.button) {
        margin-left: 10px;
      }

      .actions-button-revert {
        opacity: 0.6;
      }
      .actions-button-revert :global(.label) {
        padding: 3px 2px;
      }
    </style>
  </template>
  @tracked
  isCorrectingConflict = false;

  @tracked
  isUncorrectingConflict = false;

  @tracked
  isUpdatingText = false;

  @tracked
  inputDisabled = this.args.translation.isRemoved;

  @tracked
  text = this.args.translation.correctedText;

  get latestActivity() {
    if (!this.args.translation) return;

    return this.args.translation.latestActivities.entries[0];
  }

  get revisionSlug() {
    return (
      this.args.translation.revision.slug ||
      this.args.translation.revision.language.slug
    );
  }

  get revisionTextDirRtl() {
    return this.args.translation.revision.rtl != null
      ? this.args.translation.revision.rtl
      : this.args.translation.revision.language.rtl;
  }

  get samePreviousText() {
    return (
      this.args.translation.conflictedText ===
      this.args.translation.correctedText
    );
  }

  get hasTextNotChanged() {
    if (!this.args.translation) return false;

    return this.text === this.args.translation.correctedText;
  }

  @action
  setOriginalText() {
    this.text = this.args.translation.correctedText;
    this.args.onChangeText?.(this.text);
  }

  @action
  async correctConflict() {
    this.isCorrectingConflict = true;

    await this.args.onCorrectConflict(this.text);

    this.isCorrectingConflict = false;
  }

  @action
  onUpdateText(text: string) {
    this.text = text;
    this.inputDisabled = false;
    this.args.onChangeText?.(text);
  }

  @action
  onUpdatingText() {
    this.inputDisabled = true;
  }

  @action
  async uncorrectConflict() {
    this.isUncorrectingConflict = true;

    await this.args.onUncorrectConflict(this.text);

    this.isUncorrectingConflict = false;
  }

  @action
  async updateText() {
    this.isUpdatingText = true;

    await this.args.onUpdateText(this.text);

    this.isUpdatingText = false;
  }

  @action
  didUpdateCorrectedText(element: HTMLElement) {
    if (this.args.translation) {
      this.text = this.args.translation.correctedText;
      next(this, () => this.focusTextarea(element));
    }
  }

  @action
  changeText(text: string) {
    this.text = text;
    this.args.onChangeText?.(text);
  }

  @action
  focusTextarea(element: HTMLElement) {
    if (!this.text) return;
    const focusable = element.querySelector('textarea');
    focusable?.focus();
    focusable?.setSelectionRange(this.text.length, this.text.length);
  }
}
