import Component from '@glimmer/component';
import {LinkTo} from '@ember/routing';
import Item from 'accent-webapp/components/projects-list/item/index';
import EmptyContent from 'accent-webapp/components/empty-content/index';
import t from 'ember-intl/helpers/t';
import EmptySvg from 'accent-webapp/svgs/assets/empty.svg';
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
      {{else if @query}}
        <EmptyContent
          @icon={{EmptySvg}}
          @center={{true}}
          @text={{t 'components.projects_list.no_projects_query' query=@query}}
        />
      {{else}}
        <EmptyContent @center={{true}}>
          <EmptySvg class='icon' />
          {{t 'components.projects_list.no_projects'}}
          {{#if (get @permissions 'createProject')}}
            <div class='link-section'>
              <LinkTo @route='logged-in.projects.new' class='link'>
                {{t 'components.projects_list.maybe_create_one'}}
              </LinkTo>
            </div>
          {{/if}}
        </EmptyContent>
      {{/each}}
    </ul>

    <style scoped>
      .projects-list {
        display: flex;
        flex-wrap: wrap;
        padding: 0 10px;
        margin: 10px auto 0;
        max-width: var(--screen-lg);
        position: relative;
      }

      .item {
        flex: 1 1 calc(33.3% - 10px);
        max-width: 33.3%;
      }

      .item-link {
        display: flex;
        flex-direction: column;
        text-decoration: none;
        margin: 0 10px 20px;
        transition: 0.2s ease-in-out;
        transition-property: background;
      }
      .item-link:focus {
        background: var(--background-light);
      }

      @media (max-width: 640px) {
        .item {
          max-width: none;
          width: 100%;
          flex: 1 1 auto;
        }
        .item-link {
          margin-bottom: 10px;
        }
        .projects-list {
          padding: 0;
        }
      }
    </style>
  </template>
}
