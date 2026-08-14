import {action} from '@ember/object';
import {equal} from '@ember/object/computed';
import Component from '@glimmer/component';
import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';
import {tracked} from '@glimmer/tracking';
import didUpdate from '@ember/render-modifiers/modifiers/did-update';
import {LinkTo} from '@ember/routing';
import {array, hash, fn} from '@ember/helper';
import AccBadge from 'accent-webapp/components/acc-badge/index';
import t from 'ember-intl/helpers/t';
import TimeAgoInWordsTag from 'accent-webapp/components/time-ago-in-words-tag/index';
import IntegrationLogo from 'accent-webapp/components/integration-logo/index';
import {scopedClass} from 'ember-scoped-css';
import Form from 'accent-webapp/components/translation-edit/form/index';
import Helpers from 'accent-webapp/components/translation-edit/helpers/index';
import AsyncButton from 'accent-webapp/components/async-button/index';

interface Args {
  translation: any;
  project: any;
  revisions: any[];
  onUpdateText: (translation: any, editText: string) => Promise<void>;
}

export default class TranslationEditionsListItem extends Component<Args> {
  <template>
    <li
      data-dir={{if this.revisionTextDirRtl 'rtl'}}
      class='translations-list-item item--editMode'
      {{didUpdate this.syncEditText @translation.correctedText}}
    >
      <span data-dir={{if this.revisionTextDirRtl 'rtl'}} class='item-header'>
        <LinkTo
          @route='logged-in.project.translation'
          @models={{array @project.id @translation.id}}
          class='item-link'
        >
          <AccBadge @version={{true}}>
            <span class='item-key'>
              {{#if @translation.version}}
                {{@translation.version.tag}}
              {{else}}
                {{t 'components.translations_list.latest_version_label'}}
              {{/if}}
            </span>
          </AccBadge>
        </LinkTo>

        <span class='item-meta'>
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

          {{#each
            @translation.version.lastIntegrationExecutions
            as |execution|
          }}
            <LinkTo
              @route='logged-in.project.integration-executions'
              @models={{array @project.id execution.integration.id}}
              class='item-lastExecution'
            >
              <IntegrationLogo
                @service={{execution.integration.service}}
                class={{scopedClass 'item-lastExecution-logo'}}
              />
              {{t 'components.translations_list.last_execution_label'}}
              <TimeAgoInWordsTag @date={{execution.insertedAt}} />
            </LinkTo>
          {{/each}}
        </span>
      </span>

      <div class='item-textEdit'>
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
                    @languageSlug={{this.revisionSlug}}
                    @permissions={{@permissions}}
                    @project={{@project}}
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
    </li>

    <style scoped>
      .translations-list-item {
        transition: 0.2s ease-in-out;
        transition-property: background, transform;
        display: block;
        margin: 0 0 5px;
        padding: 4px 0;
        border: 1px solid transparent;
        border-radius: var(--border-radius);
      }
      .translations-list-item[data-dir='rtl'] .item-header {
        flex-direction: row-reverse;
      }
      .translations-list-item[data-dir='rtl'] .item-header .item-meta {
        flex-direction: row-reverse;
        margin-right: 10px;
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
      .translations-list-item:focus .item-edit,
      .translations-list-item:hover .item-edit {
        transform: translateX(-40px);
        opacity: 1;
      }

      .item-meta {
        display: flex;
        align-items: center;
      }

      .item-link {
        display: flex;
        align-items: center;
        text-decoration: none;
      }

      .item-header {
        position: relative;
        display: flex;
        align-items: center;
        flex-wrap: wrap;
        margin-bottom: 1px;
        gap: 5px;
      }

      .item-key {
        font-family: var(--font-monospace);
        text-transform: none;
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
        margin-left: 5px;
        color: var(--color-grey);
        font-size: 11px;
        transition: 0.2s ease-in-out;
        transition-property: opacity, transform;
      }

      .item-lastExecution {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        margin-left: 5px;
        color: var(--color-grey);
        font-size: 11px;
        text-decoration: none;
      }
      .item-lastExecution:hover {
        color: var(--color-black);
      }

      .item-lastExecution-logo {
        width: 14px;
        height: 14px;
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
  inputDisabled = this.args.translation.isRemoved;

  @tracked
  editText = this.args.translation.correctedText;

  @equal('args.translation.valueType', 'EMPTY')
  isTextEmpty: boolean;

  @equal('args.translation.valueType', 'NULL')
  isTextNull: boolean;

  translationKey = parsedKeyProperty(this.args.translation.key);

  @action
  changeTranslationText(text: string) {
    this.editText = text;
  }

  @action
  async save() {
    this.isSaving = true;

    await this.args.onUpdateText(this.args.translation, this.editText);

    this.isSaving = false;
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

  @action
  syncEditText() {
    this.editText = this.args.translation.correctedText;
  }
}
