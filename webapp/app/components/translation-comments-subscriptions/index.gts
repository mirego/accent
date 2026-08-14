import Component from '@glimmer/component';
import t from 'ember-intl/helpers/t';
import Item from 'accent-webapp/components/translation-comments-subscriptions/item/index';

interface Args {
  collaborators: any;
  subscriptions: any;
  onCreateSubscription: (user: any) => Promise<void>;
  onDeleteSubscription: (subscription: any) => Promise<void>;
}

export default class TranslationCommentsSubscriptions extends Component<Args> {
  <template>
    <ul class='translation-comments-subscriptions'>
      <strong class='title'>
        {{t 'components.translation_comments_subscriptions.title'}}
      </strong>

      {{#each this.filteredCollaborators key='id' as |collaborator|}}
        <Item
          @subscriptions={{@subscriptions}}
          @collaborator={{collaborator}}
          @onCreateSubscription={{@onCreateSubscription}}
          @onDeleteSubscription={{@onDeleteSubscription}}
        />
      {{/each}}
    </ul>

    <style scoped>
      .translation-comments-subscriptions {
        padding: 5px 0 20px 20px;
        border-left: 1px solid var(--background-light-highlight);
      }

      .title {
        display: block;
        padding: 0 0 5px;
        margin: 0 0 2px;
        font-size: 11px;
        font-weight: bold;
        font-style: normal;
        color: var(--color-black);
      }

      @media (max-width: 640px) {
        .translation-comments-subscriptions {
          padding-left: 0;
          padding-top: 10px;
          border-top: 1px solid var(--background-light-highlight);
          border-left: 0;
        }
        .title {
          font-size: 14px;
        }
      }
    </style>
  </template>
  get filteredCollaborators() {
    return this.args.collaborators
      .filter((collaborator: any) => !collaborator.isPending)
      .filter((collaborator: any) => collaborator.role !== 'BOT');
  }
}
