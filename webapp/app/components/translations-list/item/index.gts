import {action} from '@ember/object';
import {equal} from '@ember/object/computed';
import Component from '@glimmer/component';
import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';
import {tracked} from '@glimmer/tracking';
import {on} from '@ember/modifier';
import {fn, array, concat, hash} from '@ember/helper';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
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
            <span role='button' {{on 'click' (fn this.toggleEdit)}}>
              {{#if this.isInEditMode}}
                {{inlineSvg
                  'assets/x.svg'
                  class=(scopedClass 'item-edit-icon')
                }}
              {{else}}
                {{inlineSvg
                  'assets/pencil.svg'
                  class=(scopedClass 'item-edit-icon')
                }}
              {{/if}}
            </span>
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
                {{inlineSvg '/assets/warning.svg'}}
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
                  {{inlineSvg '/assets/warning.svg'}}
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
