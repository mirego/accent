import Component from '@glimmer/component';
import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';
import {LinkTo} from '@ember/routing';
import {array, hash} from '@ember/helper';
import ChevronLeftSvg from 'accent-webapp/svgs/assets/chevron-left.svg';
import WarningSvg from 'accent-webapp/svgs/assets/warning.svg';
import {scopedClass} from 'ember-scoped-css';
import AccBadge from 'accent-webapp/components/acc-badge/index';
import t from 'ember-intl/helpers/t';
import timeAgoInWords from 'accent-webapp/helpers/time-ago-in-words';
import TimeAgoInWordsTag from 'accent-webapp/components/time-ago-in-words-tag/index';

interface Args {
  project: any;
  translation: any;
  withRevisionLink?: boolean;
}

export default class TranslationSplashTitle extends Component<Args> {
  <template>
    <div class='translation-splash-file'>
      {{#if this.withRevisionLink}}
        <LinkTo
          @route='logged-in.project.revision.translations'
          @models={{array @project.id @translation.revision.id}}
          class='language'
        >
          <ChevronLeftSvg class={{scopedClass 'back-icon'}} />
          {{this.revisionName}}
        </LinkTo>
      {{/if}}

      <h1 class='key'>
        <small class='key-prefix'>
          {{#if this.translationKey.prefix}}
            {{this.translationKey.prefix}}
          {{else}}
            {{@translation.document.path}}
          {{/if}}
        </small>
        {{this.translationKey.value}}
      </h1>

      <div class='badges'>
        {{#if @translation.version}}
          <AccBadge @version={{true}}>
            {{@translation.version.tag}}
          </AccBadge>
        {{/if}}

        {{#if @translation.plural}}
          <AccBadge @link={{true}}>
            <LinkTo
              @route='logged-in.project.revision.translations'
              @models={{array @project.id @translation.revision.id}}
            >
              {{t 'components.translation_splash_title.plural_label'}}
            </LinkTo>
          </AccBadge>
        {{/if}}

        {{#if @translation.isRemoved}}
          <div class='removedBadge'>
            {{t
              'components.translation_splash_title.removed_label'
              removedAt=(timeAgoInWords @translation.updatedAt)
            }}
          </div>
        {{else if @translation.isConflicted}}
          <AccBadge @link={{this.withRevisionLink}} @primary={{true}}>
            {{#if this.withRevisionLink}}
              <LinkTo
                @route='logged-in.project.conflicts'
                @model={{@project.id}}
                @query={{hash query=@translation.id}}
              >
                {{t 'components.translation_splash_title.conflicted_label'}}
              </LinkTo>
            {{else}}
              {{t 'components.translation_splash_title.conflicted_label'}}
            {{/if}}
          </AccBadge>
        {{/if}}

        {{#if @translation.revision.isMaster}}
          <AccBadge>
            {{t 'components.translation_splash_title.master_label'}}
          </AccBadge>
        {{/if}}

        {{#if @translation.lintMessages}}
          <AccBadge
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
        {{/if}}

        <span class='updatedAt'>
          {{t 'components.translation_splash_title.last_updated_label'}}
          <TimeAgoInWordsTag @date={{@translation.updatedAt}} />
        </span>
      </div>
    </div>

    <style scoped>
      .translation-splash-file {
        margin-bottom: 20px;
      }

      .language {
        display: inline-block;
        margin-bottom: 4px;
        color: var(--color-black);
        font-size: 14px;
        text-decoration: none;
        transition: 0.2s ease-in-out;
        transition-property: color;
      }
      .language:focus,
      .language:hover {
        opacity: 0.8;
      }
      .language:focus .back-icon,
      .language:hover .back-icon {
        transform: translateX(-2px);
      }

      .updatedAt {
        color: var(--color-grey);
        font-size: 11px;
        font-style: italic;
      }

      .back-icon {
        width: 11px;
        height: 11px;
        stroke: var(--color-black);
        transition: 0.2s ease-in-out;
        transition-property: stroke transform;
      }

      .key {
        margin-bottom: 3px;
        font-family: var(--font-monospace);
        font-weight: bold;
        font-size: 22px;
        color: var(--color-primary);
        line-height: 1.3;
      }

      .key-prefix {
        display: block;
        font-weight: 300;
        font-size: 14px;
        color: var(--color-grey);
      }

      .removedBadge {
        font-size: 12px;
        color: var(--color-error);
      }

      .badges {
        display: flex;
        align-items: center;
      }
      .badges > * {
        margin-right: 6px;
      }

      @media (max-width: 640px) {
        .language {
          margin-top: 20px;
        }
      }
    </style>
  </template>
  withRevisionLink = this.args.withRevisionLink ?? true;

  translationKey = parsedKeyProperty(this.args.translation.key);

  get revisionName() {
    return (
      this.args.translation.revision.name ||
      this.args.translation.revision.language.name
    );
  }
}
