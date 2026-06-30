import Component from '@glimmer/component';
import Item from 'accent-webapp/components/project-settings/manage-languages/overview/item/index';

interface Args {
  permissions: Record<string, true>;
  project: any;
  revisions: any;
  onPromoteMaster: () => void;
  onDelete: () => void;
}

export default class Overview extends Component<Args> {
  <template>
    <ul class='list'>
      {{#each @revisions key='id' as |revision|}}
        <Item
          @master={{revision.isMaster}}
          @permissions={{@permissions}}
          @onPromoteMaster={{@onPromoteMaster}}
          @onDelete={{@onDelete}}
          @project={{@project}}
          @revision={{revision}}
        />
      {{/each}}
    </ul>
  </template>
}
