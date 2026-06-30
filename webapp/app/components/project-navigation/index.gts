import {action} from '@ember/object';
import {service} from '@ember/service';
import {readOnly} from '@ember/object/computed';
import {tracked} from '@glimmer/tracking';
import Component from '@glimmer/component';
import GlobalState from 'accent-webapp/services/global-state';
import RouterService from '@ember/routing/router-service';
import {timeout, restartableTask} from 'ember-concurrency';
import Session from 'accent-webapp/services/session';
import {LinkTo} from '@ember/routing';
import ProjectLogo from 'accent-webapp/components/project-logo/index';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import {scopedClass} from 'ember-scoped-css';
import t from 'ember-intl/helpers/t';
import {on} from '@ember/modifier';
import List from 'accent-webapp/components/project-navigation/list/index';
import AccAvatarImg from 'accent-webapp/components/acc-avatar-img/index';
import not from 'ember-truth-helpers/helpers/not';
import ApplicationFooter from 'accent-webapp/components/application-footer/index';

const DEBOUNCE_OFFSET = 500; // ms

interface Args {
  project: any;
  permissions: Record<string, true>;
  revisions: any;
}

export default class ProjectNavigation extends Component<Args> {
  <template>
    <div class='project-navigation'>
      <div>
        <LinkTo
          @route='logged-in.project.index'
          @model={{@project.id}}
          class='project'
        >
          <span class='project-logo'>
            <ProjectLogo @logo={{@project.logo}} />
          </span>

          <span class='project-name'>
            {{@project.name}}
          </span>
        </LinkTo>
        <div class='search'>
          {{inlineSvg '/assets/search.svg' class=(scopedClass 'search-icon')}}
          <input
            type='text'
            placeholder={{t 'general.search_input_placeholder_text'}}
            value={{this.debouncedQuery}}
            class='search-input'
            {{on 'keyup' this.setDebouncedQuery}}
          />
        </div>
        <List
          @selectedRevision={{this.selectedRevision}}
          @permissions={{@permissions}}
          @project={{@project}}
        />
      </div>

      <div class='footer'>
        <LinkTo @route='logged-in.projects' class='back-to-projects'>

          {{inlineSvg
            '/assets/chevron-left.svg'
            class=(scopedClass 'back-to-projects-icon')
          }}
          <span class='back-to-projects-text'>{{t
              'components.project_navigation.back_to_projects'
            }}</span>
        </LinkTo>

        {{#if this.session.credentials.user}}
          <div class='session'>
            <AccAvatarImg
              @showFallback={{not this.session.credentials.user.pictureUrl}}
              src={{this.session.credentials.user.pictureUrl}}
              class='session-picture'
            />

            <span class='session-username'>
              {{this.session.credentials.user.fullname}}
            </span>
          </div>
        {{/if}}

        <ApplicationFooter />
      </div>
    </div>
  </template>
  @service('session')
  declare session: Session;

  @service('global-state')
  declare globalState: GlobalState;

  @service('router')
  declare router: RouterService;

  @tracked
  debouncedQuery = '';

  get selectedRevision() {
    const selected = this.globalState.revision;

    if (
      selected &&
      this.args.revisions.map(({id}: {id: string}) => id).includes(selected)
    ) {
      return selected;
    }

    if (!this.args.revisions) return;

    return this.args.revisions[0].id;
  }

  debounceQuery = restartableTask(async (query: string) => {
    this.debouncedQuery = query;
    if (!this.debouncedQuery) return;

    await timeout(DEBOUNCE_OFFSET);

    this.router.transitionTo(
      'logged-in.project.revision.translations',
      this.args.project.id,
      this.selectedRevision,
      {
        queryParams: {query}
      }
    );

    this.debouncedQuery = '';
  });

  @action
  setDebouncedQuery(event: Event) {
    const target = event.target as HTMLInputElement;

    this.debounceQuery.perform(target.value);
  }
}
