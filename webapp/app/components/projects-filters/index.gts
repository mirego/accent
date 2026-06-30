import {action} from '@ember/object';
import {service} from '@ember/service';
import Component from '@glimmer/component';
import Session from 'accent-webapp/services/session';
import {timeout, restartableTask} from 'ember-concurrency';
import {tracked} from '@glimmer/tracking';
import {on} from '@ember/modifier';
import {fn, get} from '@ember/helper';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
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

            {{inlineSvg '/assets/search.svg' class=(scopedClass 'search-icon')}}
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
              {{inlineSvg '/assets/add.svg' class='button-icon'}}
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
