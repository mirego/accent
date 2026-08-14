import {action} from '@ember/object';
import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import {LinkTo} from '@ember/routing';
import {array, hash, fn} from '@ember/helper';
import t from 'ember-intl/helpers/t';
import TimeAgoInWordsTag from 'accent-webapp/components/time-ago-in-words-tag/index';
import AccBadge from 'accent-webapp/components/acc-badge/index';
import Form from 'accent-webapp/components/translation-edit/form/index';
import Helpers from 'accent-webapp/components/translation-edit/helpers/index';
import AsyncButton from 'accent-webapp/components/async-button/index';

interface Args {
  onUpdateText: (translation: any, editText: string) => Promise<void>;
  isInEditMode: boolean;
  showEditButton: boolean;
  translation: any;
  project: any;
}

export default class RelatedTranslationsListItem extends Component<Args> {
  <template>
    <li class='related-translations-list-item'>
      <div class='header'>
        <div>
          <LinkTo
            @route='logged-in.project.translation'
            @models={{array @project.id @translation.id}}
            tabindex='-1'
            class='revision'
          >
            {{this.revisionName}}

            <span class='updatedAt'>
              {{t 'components.related_translations_list.last_updated_label'}}
              <TimeAgoInWordsTag @date={{@translation.updatedAt}} />
            </span>
          </LinkTo>
        </div>

        <div class='badges'>
          {{#unless @translation.isRemoved}}
            {{#if @translation.commentsCount}}
              <AccBadge @link={{true}}>
                <LinkTo
                  tabindex='-1'
                  @route='logged-in.project.translation.comments'
                  @models={{array @project.id @translation.id}}
                >
                  {{t
                    'components.related_translations_list.comments_label'
                    count=@translation.commentsCount
                  }}
                </LinkTo>
              </AccBadge>
            {{/if}}

            {{#if @translation.isConflicted}}
              <AccBadge @link={{true}}>
                <LinkTo
                  tabindex='-1'
                  @route='logged-in.project.conflicts'
                  @model={{@project.id}}
                  @query={{hash query=@translation.id}}
                >
                  {{t 'components.related_translations_list.conflicted_label'}}
                </LinkTo>
              </AccBadge>
            {{/if}}
          {{/unless}}

          {{#if @translation.revision.isMaster}}
            <AccBadge>
              {{t 'components.related_translations_list.master_label'}}
            </AccBadge>
          {{/if}}
        </div>
      </div>

      <Form
        @projectId={{@project.id}}
        @permissions={{@permissions}}
        @lintMessages={{@translation.lintMessages}}
        @translationId={{@translation.id}}
        @translationKey={{@translation.key}}
        @inputDisabled={{this.inputDisabled}}
        @valueType={{@translation.valueType}}
        @value={{this.editText}}
        @originalValue={{@translation.correctedText}}
        @onKeyUp={{fn this.changeText}}
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
              <AsyncButton
                @onClick={{fn this.save}}
                @loading={{this.isSaving}}
                class='button button--filled
                  {{if form.isTextUnchanged "button--unchanged"}}'
              >
                {{t 'components.related_translations_list.save_button'}}
              </AsyncButton>
            {{/unless}}
          </div>
        </form.submit>
      </Form>
    </li>

    <style scoped>
      .textEdit-input {
        transition: 0.2s ease-in-out;
        transition-property: background, border, box-shadow;
        resize: vertical;
        outline: 0;
        border-radius: var(--border-radius);
        border: 2px solid var(--input-border-color);
        background: var(--input-background);
        color: var(--input-color);
        font-family: var(--font-monospace);
        line-height: 1.4;
        max-height: 200px;
      }
      .textEdit-input::-moz-selection {
        background: color-mix(in srgb, var(--color-primary) 70%, transparent);
      }
      .textEdit-input::selection {
        background: color-mix(in srgb, var(--color-primary) 70%, transparent);
      }
      .textEdit-input:focus {
        border: 2px solid var(--color-primary);
      }
      .textEdit-input:disabled {
        color: var(--color-grey);
        background: var(--background-light);
      }

      @media (hover: none) and (max-width: 640px) {
        .textEdit-input {
          font-size: 16px !important;
        }
      }
      .related-translations-list-item {
        position: relative;
        margin-bottom: 6px;
      }
      .related-translations-list-item.empty {
        padding: 35px 10px;
        color: var(--color-grey);
        font-size: 13px;
        font-style: italic;
        text-align: center;
      }
      .related-translations-list-item:hover .form-helpers {
        pointer-events: all;
        opacity: 1;
      }

      .badges {
        flex-shrink: 0;
      }

      .textEmpty {
        margin-bottom: 15px;
      }

      .revision {
        display: flex;
        align-items: center;
        margin-right: 4px;
        color: var(--color-black);
        text-decoration: none;
        font-weight: bold;
        font-size: 12px;
      }
      .revision:focus,
      .revision:hover {
        color: var(--color-primary);
      }

      .updatedAt {
        margin: 0 6px;
        opacity: 0.6;
        color: var(--color-black);
        font-size: 11px;
        font-style: italic;
        font-weight: normal;
      }

      .form-helpers {
        pointer-events: none;
        opacity: 0;
        position: relative;
        z-index: 1;
        transition: 0.2s ease-in-out;
        transition-property: opacity;
      }

      .header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        min-height: 25px;
        margin-bottom: 3px;
      }

      .textEdit-input {
        width: 100%;
        padding: 10px;
        margin-bottom: 6px;
        font-size: 12px;
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
        flex-direction: row-reverse;
        right: auto;
        left: 14px;
      }

      .textEdit-actions-translate {
        margin-right: 5px;
        background: none;
      }

      .textEdit-actions-translate-icon {
        width: 12px;
        height: 12px;
      }
    </style>
  </template>
  @tracked
  isSaving = false;

  @tracked
  inputDisabled = this.args.translation.isRemoved;

  @tracked
  editText = this.args.translation.correctedText;

  get revisionName() {
    return (
      this.args.translation.revision.name ||
      this.args.translation.revision.language.name
    );
  }

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
  onUpdateText(value: string) {
    this.editText = value;
    this.inputDisabled = false;
  }

  @action
  onUpdatingText() {
    this.inputDisabled = true;
  }

  @action
  changeText(text: string) {
    this.editText = text;
  }

  @action
  async save() {
    this.isSaving = true;

    await this.args.onUpdateText(this.args.translation, this.editText);

    this.isSaving = false;
  }
}
