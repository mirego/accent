import {action} from '@ember/object';
import {service} from '@ember/service';
import Component from '@glimmer/component';
import Session from 'accent-webapp/services/session';
import {timeout, restartableTask} from 'ember-concurrency';
import {tracked} from '@glimmer/tracking';
import {on} from '@ember/modifier';
import {fn, get} from '@ember/helper';
import AddSvg from 'accent-webapp/svgs/assets/add.svg';
import SearchSvg from 'accent-webapp/svgs/assets/search.svg';
import {scopedClass} from 'ember-scoped-css';
import t from 'ember-intl/helpers/t';
import {LinkTo} from '@ember/routing';

const DEBOUNCE_OFFSET = 1000; // ms

interface Args {
  permissions: any;
  query: any;
  onChangeQuery: (query: string) => void;
}

export default class ProjectsFilter extends Component<Args> {
  <template>
    <div class='filters filters--transparent local-filters'>
      <form
        class='filters-wrapper local-filters-wrapper'
        {{on 'submit' (fn this.submitForm)}}
      >
        <div class='queryFilter'>
          <div class='queryForm-search'>

            <SearchSvg class={{scopedClass 'search-icon'}} />
            <input
              type='text'
              placeholder={{t
                'components.projects_filters.input_placeholder_text'
              }}
              value={{this.debouncedQuery}}
              class='input'
              {{on 'keyup' this.setDebouncedQuery}}
            />
          </div>
        </div>

        {{#unless this.debouncedQuery}}
          {{#if (get @permissions 'createProject')}}
            <LinkTo
              @route='logged-in.projects.new'
              class='button button--filled button--green createProjectButton'
            >
              <AddSvg class='button-icon' />
              {{t 'components.projects_filters.new_project'}}
            </LinkTo>
          {{/if}}
        {{/unless}}
      </form>

      <div class='filters-meta'>
        {{#if @query}}
          {{t 'components.projects_filters.searching_for'}}
          <em class='filters-meta-keyword'>
            {{@query}}
          </em>
        {{/if}}
      </div>
    </div>

    <style scoped>
      .input {
        transition: 0.2s ease-in-out;
        transition-property: background, border, box-shadow;
        resize: vertical;
        outline: 0;
        border-radius: var(--border-radius);
        border: 2px solid var(--input-border-color);
        background: var(--input-background);
        color: var(--input-color);
        font-family: var(--font-monospace);
        line-height: 1.4;
        max-height: 200px;
      }
      .input::-moz-selection {
        background: color-mix(in srgb, var(--color-primary) 70%, transparent);
      }
      .input::selection {
        background: color-mix(in srgb, var(--color-primary) 70%, transparent);
      }
      .input:focus {
        border: 2px solid var(--color-primary);
      }
      .input:disabled {
        color: var(--color-grey);
        background: var(--background-light);
      }

      @media (hover: none) and (max-width: 640px) {
        .input {
          font-size: 16px !important;
        }
      }
      .local-filters:global(.filters) {
        margin: 20px auto 0;
        padding: 0 20px !important;
        max-width: var(--screen-lg);
      }

      .local-filters-wrapper {
        display: flex;
        align-items: center;
        justify-content: space-between;
      }

      .queryFilter {
        flex: 1;
      }

      .queryForm-search {
        width: 100%;
        position: relative;
      }

      .totalEntries {
        margin-left: 20px;
        color: var(--color-grey);
        font-size: 13px;
        font-style: italic;
      }

      .search-icon {
        position: absolute;
        top: 50%;
        margin-top: -10px;
        left: 7px;
        width: 20px;
        height: 20px;
        stroke: var(--input-border-color);
      }

      .createProjectButton {
        margin-left: 15px !important;
      }

      .input {
        width: 100%;
        padding: 7px 7px 7px 30px;
        font-size: 14px;
        font-family: var(--font-primary);
        color: var(--color-black);
      }
      .input::placeholder {
        color: var(--color-grey);
      }
      .input:focus {
        border-color: var(--color-green);
      }

      .filters-meta {
        margin-top: 7px;
        font-size: 14px;
        color: var(--color-grey);
      }

      .filters-meta-keyword {
        font-style: italic;
        color: var(--color-green);
      }

      @media (max-width: 640px) {
        div.local-filters {
          padding: 0 10px;
        }
        .local-filters:global(.filters) {
          margin: 10px auto 0;
          padding: 0 10px !important;
        }
      }
    </style>
  </template>
  @service('session')
  declare session: Session;

  @tracked
  debouncedQuery: string = this.args.query;

  debounceQueryTask = restartableTask(async (query: string) => {
    this.debouncedQuery = query;

    await timeout(DEBOUNCE_OFFSET);

    this.args.onChangeQuery(query);
  });

  @action
  setDebouncedQuery(event: Event) {
    const target = event.target as HTMLInputElement;

    this.debounceQueryTask.perform(target.value);
  }

  @action
  submitForm(event: Event) {
    event.preventDefault();

    this.args.onChangeQuery(this.debouncedQuery);
  }
}
