import Component from '@glimmer/component';
import {service} from '@ember/service';
import EmptyHero from 'accent-webapp/components/empty-hero/index';
import Item from 'accent-webapp/components/project-comments-list/item/index';
import t from 'ember-intl/helpers/t';
import IntlService from 'ember-intl/services/intl';
import ActivitySvg from 'accent-webapp/svgs/assets/activity.svg';
import EyeSvg from 'accent-webapp/svgs/assets/eye.svg';
import UsersSvg from 'accent-webapp/svgs/assets/users.svg';

interface Args {
  project: any;
  comments: any;
  onUpdateComment: (comment: {id: string; text: string}) => Promise<void>;
  onDeleteComment: (comment: {id: string}) => Promise<void>;
}

export default class ProjectCommentsList extends Component<Args> {
  <template>
    {{#if this.commentsByTranslation.length}}
      <ul class='project-comments-list'>
        {{#each this.commentsByTranslation as |groupedComment|}}
          <Item
            @project={{@project}}
            @groupedComment={{groupedComment}}
            @onDeleteComment={{@onDeleteComment}}
            @onUpdateComment={{@onUpdateComment}}
          />
        {{/each}}
      </ul>
    {{else}}
      <EmptyHero
        @title={{t 'components.project_comments_list.empty_title'}}
        @text={{t 'components.project_comments_list.empty_text'}}
        @features={{this.features}}
      />
    {{/if}}

    <style scoped>
      .project-comments-list {
        display: block;
        margin-top: 20px;
      }
    </style>
  </template>
  @service('intl')
  declare intl: IntlService;

  get features() {
    return [
      {
        icon: EyeSvg,
        title: this.intl.t(
          'components.project_comments_list.empty_feature_context_title'
        ),
        text: this.intl.t(
          'components.project_comments_list.empty_feature_context_text'
        )
      },
      {
        icon: UsersSvg,
        title: this.intl.t(
          'components.project_comments_list.empty_feature_collaborate_title'
        ),
        text: this.intl.t(
          'components.project_comments_list.empty_feature_collaborate_text'
        )
      },
      {
        icon: ActivitySvg,
        title: this.intl.t(
          'components.project_comments_list.empty_feature_history_title'
        ),
        text: this.intl.t(
          'components.project_comments_list.empty_feature_history_text'
        )
      }
    ];
  }

  get translationsById() {
    return this.args.comments
      .map((comment: any) => comment.translation)
      .reduce((memo: Record<string, any>, translation: any) => {
        if (!memo[translation.id]) memo[translation.id] = translation;

        return memo;
      }, {});
  }

  get commentsByTranslationId() {
    return this.args.comments.reduce(
      (memo: Record<string, any[]>, comment: any) => {
        memo[comment.translation.id] = memo[comment.translation.id] || [];
        memo[comment.translation.id].push(comment);

        return memo;
      },
      {}
    );
  }

  get commentsByTranslation() {
    return Object.keys(this.commentsByTranslationId).map((translationId) => {
      return {
        items: this.commentsByTranslationId[translationId],
        value: this.translationsById[translationId]
      };
    });
  }
}
