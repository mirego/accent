import {action} from '@ember/object';
import Component from '@glimmer/component';
import Item from 'accent-webapp/components/project-settings/collaborators/list/item/index';
import {fn} from '@ember/helper';

interface Args {
  permissions: Record<string, true>;
  collaborators: any;
  onDelete: (collaborator: any) => void;
  onUpdate: (collaborator: any, args: any) => void;
}

export default class CollaboratorsList extends Component<Args> {
  <template>
    <ul data-test-collaborators-list>
      {{#each this.filteredCollaborators key='id' as |collaborator|}}
        <Item
          @collaborator={{collaborator}}
          @permissions={{@permissions}}
          @onUpdate={{fn this.updateCollaborator}}
          @onDelete={{fn this.deleteCollaborator}}
        />
      {{/each}}
    </ul>
  </template>
  get filteredCollaborators() {
    return this.args.collaborators.filter((collaborator: any) => {
      return collaborator.isPending || !collaborator.user.isBot;
    });
  }

  @action
  deleteCollaborator(collaborator: any) {
    return this.args.onDelete(collaborator);
  }

  @action
  updateCollaborator(collaborator: any, args: any) {
    return this.args.onUpdate(collaborator, args);
  }
}
