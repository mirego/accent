import Component from '@glimmer/component';
import {LinkTo} from '@ember/routing';
import ActivitySvg from 'accent-webapp/svgs/assets/activity.svg';
import BubbleSvg from 'accent-webapp/svgs/assets/bubble.svg';
import CheckSvg from 'accent-webapp/svgs/assets/check.svg';
import FileSvg from 'accent-webapp/svgs/assets/file.svg';
import GearSvg from 'accent-webapp/svgs/assets/gear.svg';
import HomeSvg from 'accent-webapp/svgs/assets/home.svg';
import LanguageSvg from 'accent-webapp/svgs/assets/language.svg';
import PencilSvg from 'accent-webapp/svgs/assets/pencil.svg';
import SearchSvg from 'accent-webapp/svgs/assets/search.svg';
import ShareSvg from 'accent-webapp/svgs/assets/share.svg';
import TagSvg from 'accent-webapp/svgs/assets/tag.svg';
import UsersSvg from 'accent-webapp/svgs/assets/users.svg';
import WarningSvg from 'accent-webapp/svgs/assets/warning.svg';
import {scopedClass} from 'ember-scoped-css';
import t from 'ember-intl/helpers/t';
import {get, array} from '@ember/helper';

interface Args {
  selectedRevision: any;
  permissions: Record<string, true>;
  project: any;
}

export default class ProjectNavigationList extends Component<Args> {
  <template>
    <ul class='project-navigation-list'>
      <li class='list-item'>
        <LinkTo
          @route='logged-in.project.index'
          @model={{@project.id}}
          class='list-item-link'
        >
          <HomeSvg class={{scopedClass 'list-item-link-icon'}} />
          <span class='list-item-link-text'>
            {{t 'components.project_navigation.dashboard_link_title'}}
          </span>
        </LinkTo>
      </li>

      <div class='section'>
        <strong class='section-title'>
          {{t 'components.project_navigation.revise'}}
        </strong>

        {{#if (get @permissions 'indexTranslations')}}
          <li class='list-item'>
            <LinkTo
              @route='logged-in.project.revision.translations'
              @models={{array @project.id @selectedRevision}}
              class='list-item-link'
            >
              <SearchSvg class={{scopedClass 'list-item-link-icon'}} />
              <span class='list-item-link-text'>
                {{t 'components.project_navigation.translations_link_title'}}
              </span>
            </LinkTo>
          </li>
        {{/if}}

        {{#if (get @permissions 'correctTranslation')}}
          <li class='list-item'>
            <LinkTo
              @route='logged-in.project.conflicts'
              @model={{@project.id}}
              class='list-item-link'
            >
              <CheckSvg class={{scopedClass 'list-item-link-icon'}} />
              <span class='list-item-link-text'>
                {{t 'components.project_navigation.conflicts_link_title'}}
              </span>
            </LinkTo>
          </li>
        {{else if (get @permissions 'updateTranslation')}}
          <li class='list-item'>
            <LinkTo
              @route='logged-in.project.conflicts'
              @model={{@project.id}}
              class='list-item-link'
            >
              <PencilSvg class={{scopedClass 'list-item-link-icon'}} />
              <span class='list-item-link-text'>
                {{t 'components.project_navigation.translate_link_title'}}
              </span>
            </LinkTo>
          </li>
        {{/if}}

        {{#if (get @permissions 'lint')}}
          <li class='list-item'>
            <LinkTo
              @route='logged-in.project.revision.lint-translations'
              @models={{array @project.id @selectedRevision}}
              class='list-item-link'
            >
              <WarningSvg class={{scopedClass 'list-item-link-icon'}} />
              <span class='list-item-link-text'>
                {{t 'components.project_navigation.lint_link_title'}}
              </span>
            </LinkTo>
          </li>
        {{/if}}
      </div>

      <div class='section'>
        <strong class='section-title'>
          {{t 'components.project_navigation.engage'}}
        </strong>

        {{#if (get @permissions 'indexCollaborators')}}
          <li class='list-item'>
            <LinkTo
              @route='logged-in.project.collaborators'
              @model={{@project.id}}
              class='list-item-link'
            >
              <UsersSvg class={{scopedClass 'list-item-link-icon'}} />
              <span class='list-item-link-text'>
                {{t 'components.project_navigation.collaborators_link_title'}}
              </span>
            </LinkTo>
          </li>
        {{/if}}

        {{#if (get @permissions 'indexComments')}}
          <li class='list-item'>
            <LinkTo
              @route='logged-in.project.comments'
              @model={{@project.id}}
              class='list-item-link'
            >
              <BubbleSvg class={{scopedClass 'list-item-link-icon'}} />
              <span class='list-item-link-text'>
                {{t 'components.project_navigation.conversation_link_title'}}
              </span>
            </LinkTo>
          </li>
        {{/if}}

        {{#if (get @permissions 'indexProjectActivities')}}
          <li class='list-item'>
            <LinkTo
              @route='logged-in.project.activities'
              @model={{@project.id}}
              class='list-item-link'
            >
              <ActivitySvg class={{scopedClass 'list-item-link-icon'}} />

              <span class='list-item-link-text'>
                {{t 'components.project_navigation.activities_link_title'}}
              </span>
            </LinkTo>
          </li>
        {{/if}}
      </div>

      <div class='section'>
        <strong class='section-title'>
          {{t 'components.project_navigation.manage'}}
        </strong>

        {{#if (get @permissions 'indexRevisions')}}
          <li class='list-item'>
            <LinkTo
              @route='logged-in.project.manage-languages'
              @model={{@project.id}}
              class='list-item-link'
            >
              <LanguageSvg class={{scopedClass 'list-item-link-icon'}} />
              <span class='list-item-link-text'>
                {{t
                  'components.project_navigation.manage_languages_link_title'
                }}
              </span>
            </LinkTo>
          </li>
        {{/if}}

        {{#if (get @permissions 'indexDocuments')}}
          <li class='list-item'>
            <LinkTo
              @route='logged-in.project.files'
              @model={{@project.id}}
              class='list-item-link'
            >
              <FileSvg class={{scopedClass 'list-item-link-icon'}} />
              <span class='list-item-link-text'>
                {{t 'components.project_navigation.sync_link_title'}}
              </span>
            </LinkTo>
          </li>
        {{/if}}

        {{#if (get @permissions 'indexVersions')}}
          <li class='list-item'>
            <LinkTo
              @route='logged-in.project.versions'
              @model={{@project.id}}
              class='list-item-link'
            >
              <TagSvg class={{scopedClass 'list-item-link-icon'}} />
              <span class='list-item-link-text'>
                {{t 'components.project_navigation.versions_link_title'}}
              </span>
            </LinkTo>
          </li>
        {{/if}}

        {{#if (get @permissions 'indexProjectIntegrations')}}
          <li class='list-item'>
            <LinkTo
              @route='logged-in.project.service-integrations'
              @model={{@project.id}}
              class='list-item-link'
            >
              <ShareSvg class={{scopedClass 'list-item-link-icon'}} />
              <span class='list-item-link-text'>
                {{t
                  'components.project_navigation.service_integrations_link_title'
                }}
              </span>
            </LinkTo>
          </li>
        {{/if}}

        <li class='list-item'>
          <LinkTo
            @route='logged-in.project.edit'
            @model={{@project.id}}
            class='list-item-link'
          >
            <GearSvg class={{scopedClass 'list-item-link-icon'}} />
            <span class='list-item-link-text'>
              {{t 'components.project_navigation.settings_link_title'}}
            </span>
          </LinkTo>
        </li>
      </div>
    </ul>

    <style scoped>
      .project-navigation-list {
        display: flex;
        flex-direction: column;
        padding: 0;
        margin: 0;
      }

      .section {
        display: flex;
        flex-direction: column;
        margin: 6px 0;
        padding-bottom: 4px;
      }

      .section-title {
        display: block;
        margin-left: 0;
        margin-bottom: 2px;
        padding-bottom: 3px;
        padding-left: 14px;
        font-weight: 500;
        font-size: 12px;
        color: var(--color-grey);
        opacity: 0.9;
        width: 100%;
      }

      .list-item:last-of-type .list-item-link {
        margin-bottom: 0;
      }

      :global([data-theme='dark']) .list-item-link:global(.active) {
        color: var(--color-primary);
      }

      .list-item-link {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 7px 12px 6px;
        text-decoration: none;
        font-size: 14px;
        margin: 0 7px 0 5px;
        border-radius: var(--border-radius);
        color: var(--text-color-normal);
      }
      .list-item-link:hover,
      .list-item-link:focus {
        opacity: 1;
        background: color-mix(in srgb, var(--color-primary) 10%, transparent);
        transition: all 0.2s ease-in-out;
        color: var(--color-black);
      }
      .list-item-link:hover .list-item-link-icon,
      .list-item-link:focus .list-item-link-icon {
        transform: scale(1);
        opacity: 1;
      }
      .list-item-link:global(.active) {
        opacity: 1;
        background: color-mix(in srgb, var(--color-primary) 25%, transparent);
        color: color-mix(in srgb, var(--color-primary) 50%, black);
      }
      .list-item-link:global(.active) .list-item-link-icon {
        transform: scale(1);
        opacity: 1;
      }
      .list-item-link:global(.active) .list-item-link-text {
        opacity: 1;
      }

      .list-item-link-text {
        opacity: 0.9;
      }

      .list-item-link-icon {
        transition: 0.2s ease-in-out;
        transition-property: fill, opacity;
        display: inline-block;
        height: 15px;
        width: 15px;
        opacity: 0.9;
      }

      @media (max-width: 800px) {
        .project-navigation-list {
          margin-left: 0;
          margin-right: 0;
          --border-radius: 0;
        }
        .section-title,
        .list-item-link-text {
          display: none;
        }
        .list-item-link-icon {
          width: 20px;
          height: 20px;
        }
        .list-item-link {
          padding: 9px 12px 8px;
          margin: 0;
          justify-content: center;
        }
        .section {
          margin: 10px 0;
          padding: 0 0 14px;
          border-bottom: 1px solid
            color-mix(in srgb, var(--color-primary) 10%, transparent);
        }
      }
    </style>
  </template>
}
