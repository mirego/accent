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

    <style scoped>
      .projects {
        display: flex;
        align-items: center;
        padding: 10px;
        margin: 0 auto;
        max-width: calc(var(--screen-lg) - 25px);
      }

      .projects-title {
        display: block;
        margin-right: 10px;
        font-weight: 600;
        font-size: 12px;
        opacity: 0.7;
      }

      .projects-list {
        display: flex;
        flex-wrap: wrap;
        position: relative;
        gap: 4px 10px;
      }

      .item-link {
        display: block;
        padding: 3px 8px 4px;
        border: 1px solid var(--background-light-highlight);
        border-radius: var(--border-radius);
        text-decoration: none;
        font-weight: 600;
        transition: 0.2s ease-in-out;
        transition-property: background, box-shadow;
      }
      .item-link:focus {
        box-shadow: 0 1px 1px var(--shadow-color);
      }
      .item-link:hover {
        box-shadow: 0 2px 5px var(--shadow-color);
        background: var(--content-background);
      }

      @media (max-width: 640px) {
        .projects {
          align-items: flex-start;
          flex-direction: column;
          padding: 0;
          margin-bottom: 14px;
        }
        .projects-title {
          margin-bottom: 4px;
        }
      }
    </style>
  </template>
}
