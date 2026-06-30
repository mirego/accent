import Component from '@glimmer/component';
import {LinkTo} from '@ember/routing';
import Item from 'accent-webapp/components/projects-list/item/index';
import EmptyContent from 'accent-webapp/components/empty-content/index';
import t from 'ember-intl/helpers/t';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import {get} from '@ember/helper';

interface Args {
  permissions: Record<string, true>;
  projects: any;
  query: any;
}

export default class ProjectsList extends Component<Args> {
  <template>
    <ul data-test-projects-list class='projects-list'>
      {{#each @projects key='id' as |project index|}}
        <li data-test-project={{index}} class='item'>
          <LinkTo
            @route='logged-in.project'
            @model={{project.id}}
            class='item-link'
          >
            <Item @project={{project}} />
          </LinkTo>
        </li>
      {{else}}{{#if @query}}
          <EmptyContent
            @iconPath='assets/empty.svg'
            @center={{true}}
            @text={{t
              'components.projects_list.no_projects_query'
              query=@query
            }}
          />
        {{else}}
          <EmptyContent @center={{true}}>
            {{inlineSvg 'assets/empty.svg' class='icon'}}
            {{t 'components.projects_list.no_projects'}}
            {{#if (get @permissions 'createProject')}}
              <div class='link-section'>
                <LinkTo @route='logged-in.projects.new' class='link'>
                  {{t 'components.projects_list.maybe_create_one'}}
                </LinkTo>
              </div>
            {{/if}}
          </EmptyContent>
        {{/if}}{{/each}}
    </ul>
  </template>
}
