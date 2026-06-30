import {action} from '@ember/object';
import {service} from '@ember/service';
import Component from '@glimmer/component';
import Session from 'accent-webapp/services/session';
import RouterService from '@ember/routing/router-service';
import GlobalState from 'accent-webapp/services/global-state';
import {tracked} from '@glimmer/tracking';
import {timeout, restartableTask} from 'ember-concurrency';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import {scopedClass} from 'ember-scoped-css';
import t from 'ember-intl/helpers/t';
import {on} from '@ember/modifier';
import AccAvatarImg from 'accent-webapp/components/acc-avatar-img/index';
import {fn} from '@ember/helper';

const DEBOUNCE_OFFSET = 500; // ms

interface Args {
  session: any;
  project?: any;
}

export default class ProjectsHeader extends Component<Args> {
  <template>
    <header class='projects-header {{if @project "withProject"}}'>
      <div class='content'>
        <div class='content-left'>
          <div class='applicationLogo'>
            {{inlineSvg
              'assets/logo.svg'
              class=(scopedClass 'applicationLogo-image')
            }}
            <span class='applicationLogo-accent'>
              {{t 'general.application_name'}}
            </span>
          </div>
        </div>

        {{#if @project}}
          <div class='content-center'>
            <div class='search'>
              {{inlineSvg
                '/assets/search.svg'
                class=(scopedClass 'search-icon')
              }}
              <input
                type='text'
                placeholder={{t 'general.search_input_placeholder_text'}}
                value={{this.debouncedQuery}}
                class='search-input'
                {{on 'keyup' this.setDebouncedQuery}}
              />
            </div>
          </div>
        {{/if}}

        {{#if @session.credentials.user}}
          <div class='content-right'>
            {{#if @session.credentials.user.pictureUrl}}
              <AccAvatarImg
                src={{@session.credentials.user.pictureUrl}}
                class='picture'
              />
            {{/if}}

            <span class='username'>
              {{@session.credentials.user.fullname}}
            </span>

            {{#unless @project}}
              <button
                class='button button--white'
                {{on 'click' (fn this.logout)}}
              >
                {{t 'general.logout_button'}}
              </button>
            {{/unless}}
          </div>
        {{/if}}
      </div>
    </header>
  </template>
  @service('session')
  declare session: Session;

  @service('router')
  declare router: RouterService;

  @service('global-state')
  declare globalState: GlobalState;

  @tracked
  debouncedQuery = '';

  get selectedRevision() {
    const selected = this.globalState.revision;

    if (
      selected &&
      this.args.project.revisions
        .map(({id}: {id: string}) => id)
        .includes(selected)
    ) {
      return selected;
    }

    if (!this.args.project.revisions) return;
    return this.args.project.revisions[0].id;
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
  });

  @action
  setDebouncedQuery(event: Event) {
    const target = event.target as HTMLInputElement;

    this.debounceQuery.perform(target.value);
  }

  @action
  logout() {
    this.session.logout();
  }
}
