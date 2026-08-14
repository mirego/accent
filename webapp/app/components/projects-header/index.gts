import {action} from '@ember/object';
import {service} from '@ember/service';
import Component from '@glimmer/component';
import Session from 'accent-webapp/services/session';
import RouterService from '@ember/routing/router-service';
import GlobalState from 'accent-webapp/services/global-state';
import {tracked} from '@glimmer/tracking';
import {timeout, restartableTask} from 'ember-concurrency';
import LogoSvg from 'accent-webapp/svgs/assets/logo.svg';
import SearchSvg from 'accent-webapp/svgs/assets/search.svg';
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
            <LogoSvg class={{scopedClass 'applicationLogo-image'}} />
            <span class='applicationLogo-accent'>
              {{t 'general.application_name'}}
            </span>
          </div>
        </div>

        {{#if @project}}
          <div class='content-center'>
            <div class='search'>
              <SearchSvg class={{scopedClass 'search-icon'}} />
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

    <style scoped>
      .projects-header {
        padding: 20px 0 0;
      }

      .content {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin: 0 auto;
        max-width: var(--screen-lg);
        padding: 0 15px 0 20px;
        width: 100%;
      }

      .content-right,
      .content-left {
        display: flex;
        align-items: center;
      }

      .applicationLogo {
        display: inline-flex;
        align-items: center;
        text-decoration: none;
      }

      .link.active .link-image:focus,
      .link.active .link-image:hover {
        transform: rotate(0);
      }

      .applicationLogo-back,
      .applicationLogo-image {
        display: block;
        transition: 0.7s ease-in-out;
        transition-property: transform;
        width: 25px;
        height: 25px;
        text-decoration: none;
      }

      .applicationLogo-back {
        color: #bbb;
      }
      .applicationLogo-back:focus,
      .applicationLogo-back:hover {
        opacity: 0.8;
      }

      .applicationLogo-accent,
      .applicationLogo-name {
        margin-left: 15px;
        text-decoration: none;
        font-size: 18px;
        font-weight: 700;
        color: var(--color-black);
      }

      .picture {
        width: 18px;
        height: 18px;
        margin-right: 4px;
        border-radius: var(--border-radius);
      }

      .username {
        opacity: 0.5;
        margin-right: 15px;
        font-size: 12px;
      }

      @media (max-width: 640px) {
        .projects-header {
          padding: 10px 0;
          margin-bottom: 10px;
        }
        .projects-header .content {
          padding: 0 10px;
        }
      }
      @media (max-width: 440px) {
        .applicationLogo-image {
          width: 18px;
          height: 18px;
        }
        .username {
          font-size: 11px;
        }
        :global(.button) {
          padding: 3px 7px 4px;
          font-size: 11px;
        }
        .applicationLogo-name {
          display: none;
        }
        .project-logo {
          display: none;
        }
        .projects-header.withProject,
        .projects-header {
          padding-top: 20px;
        }
        .projects-header.withProject .content,
        .projects-header .content {
          padding: 0 12px;
        }
      }
    </style>
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
