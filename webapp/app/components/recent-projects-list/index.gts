import Component from '@glimmer/component';
import t from 'ember-intl/helpers/t';
import {LinkTo} from '@ember/routing';
import Item from 'accent-webapp/components/recent-projects-list/item/index';

interface Args {
  permissions: Record<string, true>;
  projects: any;
}

export default class RecentProjectsList extends Component<Args> {
  <template>
    {{#if @projects}}
      <div class='projects'>
        <h2 class='projects-title'>
          {{t 'components.recent_projects_list.title'}}
        </h2>

        <ul data-test-recent-projects-list class='projects-list'>
          {{#each @projects key='id' as |project index|}}
            <li data-test-recent-project={{index}}>
              <LinkTo
                @route='logged-in.project'
                @model={{project.id}}
                class='item-link'
              >
                <Item @project={{project}} />
              </LinkTo>
            </li>
          {{/each}}
        </ul>
      </div>
    {{/if}}
  </template>
}
