import Component from '@glimmer/component';
import Item from 'accent-webapp/components/project-comments-list/item/index';
import t from 'ember-intl/helpers/t';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import {scopedClass} from 'ember-scoped-css';

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
      <div class='empty'>
        <div class='empty-hero'>
          <div>
            <h3 class='empty-hero-title'>{{t
                'components.project_comments_list.empty_title'
              }}</h3>
            <p class='empty-hero-text'>{{t
                'components.project_comments_list.empty_text'
              }}</p>
          </div>
        </div>

        <ul class='empty-features'>
          <li class='empty-feature'>
            {{inlineSvg
              '/assets/eye.svg'
              class=(scopedClass 'empty-feature-icon')
            }}
            <div>
              <strong>{{t
                  'components.project_comments_list.empty_feature_context_title'
                }}</strong>
              <span>{{t
                  'components.project_comments_list.empty_feature_context_text'
                }}</span>
            </div>
          </li>

          <li class='empty-feature'>
            {{inlineSvg
              '/assets/users.svg'
              class=(scopedClass 'empty-feature-icon')
            }}
            <div>
              <strong>{{t
                  'components.project_comments_list.empty_feature_collaborate_title'
                }}</strong>
              <span>{{t
                  'components.project_comments_list.empty_feature_collaborate_text'
                }}</span>
            </div>
          </li>

          <li class='empty-feature'>
            {{inlineSvg
              '/assets/activity.svg'
              class=(scopedClass 'empty-feature-icon')
            }}
            <div>
              <strong>{{t
                  'components.project_comments_list.empty_feature_history_title'
                }}</strong>
              <span>{{t
                  'components.project_comments_list.empty_feature_history_text'
                }}</span>
            </div>
          </li>
        </ul>
      </div>
    {{/if}}
  </template>
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
