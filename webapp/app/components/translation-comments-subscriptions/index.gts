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
  </template>
  get filteredCollaborators() {
    return this.args.collaborators
      .filter((collaborator: any) => !collaborator.isPending)
      .filter((collaborator: any) => collaborator.role !== 'BOT');
  }
}
