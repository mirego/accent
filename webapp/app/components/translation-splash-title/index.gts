import Component from '@glimmer/component';
import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';
import {LinkTo} from '@ember/routing';
import {array, hash} from '@ember/helper';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
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
          {{inlineSvg
            'assets/chevron-left.svg'
            class=(scopedClass 'back-icon')
          }}
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
            {{inlineSvg '/assets/warning.svg'}}
          </AccBadge>
        {{/if}}

        <span class='updatedAt'>
          {{t 'components.translation_splash_title.last_updated_label'}}
          <TimeAgoInWordsTag @date={{@translation.updatedAt}} />
        </span>
      </div>
    </div>
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
