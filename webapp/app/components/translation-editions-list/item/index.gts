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
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import integrationLogo from 'accent-webapp/helpers/integration-logo';
import scopedClass from 'ember-scoped-css';
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
              {{inlineSvg
                (integrationLogo execution.integration.service)
                class=(scopedClass 'item-lastExecution-logo')
              }}
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
