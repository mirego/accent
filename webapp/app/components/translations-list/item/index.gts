import {action} from '@ember/object';
import {equal} from '@ember/object/computed';
import Component from '@glimmer/component';
import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';
import {tracked} from '@glimmer/tracking';
import {on} from '@ember/modifier';
import {fn, array, concat, hash} from '@ember/helper';
import PencilSvg from 'accent-webapp/svgs/assets/pencil.svg';
import WarningSvg from 'accent-webapp/svgs/assets/warning.svg';
import XSvg from 'accent-webapp/svgs/assets/x.svg';
import {scopedClass} from 'ember-scoped-css';
import {LinkTo} from '@ember/routing';
import gt from 'ember-truth-helpers/helpers/gt';
import AccBadge from 'accent-webapp/components/acc-badge/index';
import t from 'ember-intl/helpers/t';
import TimeAgoInWordsTag from 'accent-webapp/components/time-ago-in-words-tag/index';
import didInsert from '@ember/render-modifiers/modifiers/did-insert';
import Form from 'accent-webapp/components/translation-edit/form/index';
import Helpers from 'accent-webapp/components/translation-edit/helpers/index';
import AsyncButton from 'accent-webapp/components/async-button/index';
import truncate from 'accent-webapp/helpers/truncate';

interface Args {
  translation: any;
  project: any;
  revisions: any[];
  onUpdateText: (translation: any, editText: string) => Promise<void>;
}

export default class TranslationsListItem extends Component<Args> {
  <template>
    <li
      data-dir={{if this.revisionTextDirRtl 'rtl'}}
      class='translations-list-item {{if this.isInEditMode "item--editMode"}}'
    >
      <span data-dir={{if this.revisionTextDirRtl 'rtl'}} class='item-header'>
        <span class='item-edit-wrapper'>
          <span class='item-edit'>
            <button
              type='button'
              class='item-edit-button'
              {{on 'click' (fn this.toggleEdit)}}
            >
              {{#if this.isInEditMode}}
                <XSvg class={{scopedClass 'item-edit-icon'}} />
              {{else}}
                <PencilSvg class={{scopedClass 'item-edit-icon'}} />
              {{/if}}
            </button>
          </span>
          <LinkTo
            @route='logged-in.project.translation'
            @models={{array @project.id @translation.id}}
            class='item-link'
          >
            <strong class='item-key'>
              {{this.translationKey.value}}
              <small class='item-key-prefix'>
                {{#if this.translationKey.prefix}}
                  {{this.translationKey.prefix}}
                {{else}}
                  {{@translation.document.path}}
                {{/if}}
              </small>
            </strong>
          </LinkTo>
        </span>

        <span class='item-meta'>
          {{#if @translation.lintMessages}}
            {{#if (gt @translation.lintMessages.length 1)}}
              <AccBadge
                {{on 'click' (fn this.toggleEdit)}}
                @warning={{true}}
                @icon={{true}}
                class='tooltip tooltip--top'
                title={{t
                  'components.translations_list.lint_messages_label'
                  count=@translation.lintMessages.length
                }}
              >
                <WarningSvg />
              </AccBadge>
            {{else}}
              {{#each @translation.lintMessages as |message|}}
                <AccBadge
                  {{on 'click' (fn this.toggleEdit)}}
                  @warning={{true}}
                  @icon={{true}}
                  class='tooltip tooltip--top'
                  title={{if
                    message.message
                    message.message
                    (t
                      (concat
                        'components.translation_edit.lint_message.checks.'
                        message.check
                      )
                    )
                  }}
                >
                  <WarningSvg />
                </AccBadge>
              {{/each}}
            {{/if}}
          {{/if}}

          {{#if @translation.isConflicted}}
            <AccBadge
              title={{t 'components.translations_list.in_review_tooltip'}}
              class='tooltip tooltip--top'
              @link={{true}}
            >
              <LinkTo
                @route='logged-in.project.conflicts'
                @model={{@project.id}}
                @query={{hash query=@translation.id}}
              >
                {{t 'components.translations_list.in_review_label'}}
              </LinkTo>
            </AccBadge>
          {{/if}}

          {{#unless @translation.isTranslated}}
            <AccBadge
              title={{t 'components.translations_list.to_translate_tooltip'}}
              class='tooltip tooltip--top'
            >
              {{t 'components.translations_list.to_translate_label'}}
            </AccBadge>
          {{/unless}}

          {{#if @translation.commentsCount}}
            <AccBadge @link={{true}}>
              <LinkTo
                @route='logged-in.project.translation.comments'
                @models={{array @project.id @translation.id}}
              >
                {{t
                  'components.translations_list.comments_count'
                  count=@translation.commentsCount
                }}
              </LinkTo>
            </AccBadge>
          {{/if}}

          <span class='item-updatedAt'>
            {{t 'components.translations_list.last_updated_label'}}
            <TimeAgoInWordsTag @date={{@translation.updatedAt}} />
          </span>
        </span>
      </span>

      {{#if this.isInEditMode}}
        <div class='item-textEdit' {{didInsert this.focusTextarea}}>
          <Form
            @permissions={{@permissions}}
            @projectId={{@project.id}}
            @translationId={{@translation.id}}
            @translationKey={{@translation.key}}
            @lintMessages={{@translation.lintMessages}}
            @inputDisabled={{this.inputDisabled}}
            @valueType={{@translation.valueType}}
            @value={{this.editText}}
            @originalValue={{@translation.correctedText}}
            @onKeyUp={{fn this.changeTranslationText}}
            @onEscape={{fn this.toggleEdit}}
            @onSubmit={{fn this.save}}
            @rtl={{this.revisionTextDirRtl}}
            lang={{this.revisionSlug}}
            as |form|
          >
            <form.submit>
              <div data-dir={{form.dir}} class='textEdit-actions'>
                {{#unless @translation.isRemoved}}
                  <div class='form-helpers'>
                    <Helpers
                      @permissions={{@permissions}}
                      @project={{@project}}
                      @languageSlug={{this.revisionSlug}}
                      @prompts={{@prompts}}
                      @rtl={{this.revisionTextDirRtl}}
                      @text={{this.editText}}
                      @onUpdatingText={{fn this.onUpdatingText}}
                      @onUpdateText={{fn this.onUpdateText}}
                    />
                  </div>
                {{/unless}}

                <AsyncButton
                  @onClick={{fn this.save}}
                  @loading={{this.isSaving}}
                  class='button button--filled button--iconOnly
                    {{if form.isTextUnchanged "button--unchanged"}}
                    item-textEdit-button'
                >
                  {{t 'components.translations_list.save'}}
                </AsyncButton>
              </div>
            </form.submit>
          </Form>
        </div>
      {{else if this.isTextEmpty}}
        <span
          role='button'
          data-dir={{if this.revisionTextDirRtl 'rtl'}}
          class='item-text item-text--empty'
          {{on 'click' (fn this.toggleEdit)}}
        >
          {{t 'components.translations_list.empty_text'}}
        </span>
      {{else if this.isTextNull}}
        <span
          role='button'
          data-dir={{if this.revisionTextDirRtl 'rtl'}}
          class='item-text item-text--empty'
          {{on 'click' (fn this.toggleEdit)}}
        >
          {{t 'components.translations_list.null_text'}}
        </span>
      {{else}}
        <span
          role='button'
          data-dir={{if this.revisionTextDirRtl 'rtl'}}
          class='item-text'
          {{on 'click' (fn this.toggleEdit)}}
        >{{truncate @translation.correctedText 600}}</span>
      {{/if}}
    </li>

    <style scoped>
      .translations-list-item {
        transition: 0.2s ease-in-out;
        transition-property: background, transform;
        display: block;
        margin: 0 0 5px;
        padding: 4px 10px;
        border: 1px solid transparent;
        border-radius: var(--border-radius);
      }
      .translations-list-item[data-dir='rtl'] .item-header {
        flex-direction: row-reverse;
      }
      .translations-list-item[data-dir='rtl'] .item-header .item-edit-wrapper {
        flex-direction: row-reverse;
      }
      .translations-list-item[data-dir='rtl'] .item-header .item-meta {
        flex-direction: row-reverse;
        margin-right: 10px;
      }
      .translations-list-item[data-dir='rtl'] .item-header .item-updatedAt {
        margin-left: 0;
        margin-right: 10px;
      }
      .translations-list-item[data-dir='rtl'] .item-header .item-key {
        flex-direction: row-reverse;
      }
      .translations-list-item[data-dir='rtl']
        .item-header
        .item-key-prefix::before {
        content: '';
      }
      .translations-list-item[data-dir='rtl']
        .item-header
        .item-key-prefix::after {
        content: '/';
      }
      .translations-list-item:focus .form-helpers,
      .translations-list-item:hover .form-helpers {
        pointer-events: all;
        opacity: 1;
      }
      .translations-list-item:focus[data-dir='rtl'] .item-edit,
      .translations-list-item:hover[data-dir='rtl'] .item-edit {
        transform: translateX(40px);
      }
      .item-edit-button {
        background: transparent;
      }
      .item-edit-button:hover {
        outline: none;
      }
      .translations-list-item:focus .item-edit,
      .translations-list-item:hover .item-edit {
        transform: translateX(-40px);
        opacity: 1;
      }
      .translations-list-item:focus .item-updatedAt,
      .translations-list-item:hover .item-updatedAt {
        opacity: 1;
        transform: translateX(0);
      }
      .translations-list-item.item--editMode {
        background: var(--background-light);
      }
      .translations-list-item.item--editMode .item-edit {
        transform: translateX(-40px);
        opacity: 1;
      }
      .translations-list-item.item--editMode .item-edit-icon:focus,
      .translations-list-item.item--editMode .item-edit-icon:hover {
        stroke: var(--color-error);
      }

      .item-link {
        text-decoration: none;
      }
      .item-link:focus .item-key,
      .item-link:hover .item-key {
        color: color-mix(in srgb, var(--color-primary) 50%, transparent);
      }

      .item-edit-wrapper {
        display: flex;
      }

      .item-header {
        position: relative;
        display: flex;
        align-items: flex-start;
        flex-wrap: wrap;
        margin-bottom: 1px;
        gap: 5px;
      }

      .item-edit {
        position: absolute;
        opacity: 0;
        top: -3px;
        left: 7px;
        padding: 2px 8px;
        transform: translateX(-20px);
        transition: 0.2s ease-in-out;
        transition-property: opacity, transform;
      }

      .item-edit-icon {
        width: 16px;
        height: 16px;
        cursor: pointer;
        stroke: var(--color-grey);
        transition: 0.2s ease-in-out;
        transition-property: stroke;
      }
      .item-edit-icon:focus,
      .item-edit-icon:hover {
        stroke: var(--color-green);
        stroke: var(--color-primary);
      }

      .item-key-prefix {
        display: inline-flex;
        gap: 5px;
        font-size: 11px;
        color: #959595;
        flex-shrink: 0;
        font-weight: 300;
      }
      .item-key-prefix::before {
        content: '/';
      }

      .item-key {
        display: flex;
        align-items: center;
        gap: 5px;
        transition: 0.2s ease-in-out;
        transition-property: color;
        color: var(--color-primary);
        line-height: 1.5;
        word-break: break-all;
        font-family: var(--font-monospace);
        font-size: 11px;
        font-weight: bold;
      }

      .item-meta {
        display: flex;
        align-items: center;
        gap: 3px;
      }

      .item-text {
        display: block;
        width: 100%;
        font-size: 13px;
        color: var(--color-black);
        padding: 2px 0;
        cursor: text;
        white-space: pre-wrap;
        transition: 0.2s ease-in-out;
        transition-property: opacity;
        opacity: 0.8;
      }
      .item-text.item-text--empty {
        white-space: normal;
        font-style: italic;
        font-size: 11px;
        opacity: 0.4;
      }
      .item-text[data-dir='rtl'] {
        text-align: right;
      }
      .item-text:hover,
      .item-text:focus {
        opacity: 1;
      }

      .item-updatedAt {
        opacity: 0;
        transform: translateX(-5px);
        margin-left: 5px;
        color: var(--color-grey);
        font-size: 11px;
        transition: 0.2s ease-in-out;
        transition-property: opacity, transform;
      }

      .item-textEdit {
        margin-top: 10px;
        position: relative;
      }

      .item-textEdit-cancel {
        margin-right: 20px;
        color: var(--color-grey);
        font-size: 12px;
        cursor: pointer;
      }

      .item-textEdit-button {
        padding: 1px 9px !important;
      }

      .form-helpers {
        pointer-events: none;
        opacity: 0;
        position: relative;
        z-index: 1;
        transition: 0.2s ease-in-out;
        transition-property: opacity;
      }

      .textEdit-actions {
        display: flex;
        justify-content: flex-end;
        align-items: center;
        position: absolute;
        gap: 8px;
        top: 14px;
        right: 14px;
      }
      .textEdit-actions[data-dir='rtl'] {
        right: auto;
        left: 14px;
        flex-direction: row-reverse;
      }

      @media (max-width: 800px) {
        .item-edit {
          display: none;
        }
      }
    </style>
  </template>
  @tracked
  isSaving = false;

  @tracked
  isInEditMode = false;

  @tracked
  inputDisabled = this.args.translation.isRemoved;

  @tracked
  editText = this.args.translation.correctedText;

  @equal('args.translation.valueType', 'EMPTY')
  isTextEmpty: boolean;

  @equal('args.translation.valueType', 'NULL')
  isTextNull: boolean;

  translationKey = parsedKeyProperty(this.args.translation.key);

  get revisionSlug() {
    return (
      this.args.translation.revision.slug ||
      this.args.translation.revision.language.slug
    );
  }

  get revisionTextDirRtl() {
    return this.args.translation.revision.rtl !== null
      ? this.args.translation.revision.rtl
      : this.args.translation.revision.language.rtl;
  }

  @action
  changeTranslationText(text: string) {
    this.editText = text;
  }

  @action
  async save() {
    this.isSaving = true;

    await this.args.onUpdateText(this.args.translation, this.editText);

    this.isSaving = false;
    this.isInEditMode = !this.isInEditMode;
  }

  @action
  toggleEdit() {
    this.editText = this.args.translation.correctedText;
    this.isInEditMode = !this.isInEditMode;
  }

  @action
  focusTextarea(element: HTMLElement) {
    element.querySelector('textarea')?.focus();
  }

  @action
  onUpdateText(value: string) {
    this.editText = value;
    this.inputDisabled = false;
  }

  @action
  onUpdatingText() {
    this.inputDisabled = true;
  }
}
