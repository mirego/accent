import Component from '@glimmer/component';
import {action} from '@ember/object';
import {get} from '@ember/helper';
import didInsert from '@ember/render-modifiers/modifiers/did-insert';
import TranslationCommentForm from 'accent-webapp/components/translation-comment-form/index';
import TranslationCommentsList from 'accent-webapp/components/translation-comments-list/index';
import ResourcePagination from 'accent-webapp/components/resource-pagination/index';
import TranslationCommentsSubscriptions from 'accent-webapp/components/translation-comments-subscriptions/index';

interface Args {
  permissions: Record<string, true>;
  translation: any;
  collaborators: any;
  subscriptions: any;
  comments: any;
  onCreateSubscription: (user: any) => Promise<void>;
  onDeleteSubscription: (subscription: any) => Promise<void>;
  onSubmit: (text: string) => Promise<void>;
  onDeleteComment: (comment: {id: string}) => Promise<void>;
  onSelectPage: (page: number) => void;
}

export default class TranslationConversation extends Component<Args> {
  <template>
    <div class='translation-conversation'>
      <div class='comments'>
        {{#if (get @permissions 'createComment')}}
          {{#unless @translation.isRemoved}}
            <div class='comment-form' {{didInsert this.focusTextarea}}>
              <TranslationCommentForm @onSubmit={{@onSubmit}} />
            </div>
          {{/unless}}
        {{/if}}

        <div class='list'>
          <TranslationCommentsList
            @comments={{@comments.entries}}
            @onUpdateComment={{@onUpdateComment}}
            @onDeleteComment={{@onDeleteComment}}
            class='at-translation'
          />

          <ResourcePagination
            @meta={{@comments.meta}}
            @onSelectPage={{@onSelectPage}}
          />
        </div>
      </div>

      <div class='subscriptions'>
        <TranslationCommentsSubscriptions
          @collaborators={{@collaborators}}
          @subscriptions={{@subscriptions}}
          @onCreateSubscription={{@onCreateSubscription}}
          @onDeleteSubscription={{@onDeleteSubscription}}
        />
      </div>
    </div>

    <style scoped>
      .translation-conversation {
        display: flex;
        width: 100%;
      }

      .comments {
        flex: 1 1 100%;
      }

      .comment-form {
        margin: 0 0 32px 0;
      }

      .list {
        margin-top: 30px;
      }

      .subscriptions {
        flex: 1 1 100%;
        max-width: 250px;
        margin: 30px 0 0 25px;
      }

      @media (max-width: 640px) {
        .translation-conversation {
          flex-direction: column;
        }
        .subscriptions {
          max-width: none;
          margin-top: 10px;
          margin-left: 0;
        }
      }
    </style>
  </template>
  @action
  focusTextarea(element: HTMLElement) {
    element.querySelector('textarea')?.focus();
  }
}
