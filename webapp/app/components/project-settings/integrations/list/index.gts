import Component from '@glimmer/component';
import Item from 'accent-webapp/components/project-settings/integrations/list/item/index';

interface Args {
  permissions: Record<string, true>;
  project: any;
  integrations: any;
  onUpdate: () => void;
  onDelete: () => void;
}

export default class IntegrationsList extends Component<Args> {
  <template>
    <ul class='project-settings-integrations-list'>
      {{#each @integrations key='id' as |integration|}}
        <Item
          @project={{@project}}
          @permissions={{@permissions}}
          @integration={{integration}}
          @onUpdate={{@onUpdate}}
          @onDelete={{@onDelete}}
        />
      {{/each}}
    </ul>
  </template>
}
