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
