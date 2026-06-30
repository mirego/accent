import Component from '@glimmer/component';
import {LinkTo} from '@ember/routing';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
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
          {{inlineSvg
            '/assets/home.svg'
            class=(scopedClass 'list-item-link-icon')
          }}
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
              {{inlineSvg
                '/assets/search.svg'
                class=(scopedClass 'list-item-link-icon')
              }}
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
              {{inlineSvg
                '/assets/check.svg'
                class=(scopedClass 'list-item-link-icon')
              }}
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
              {{inlineSvg
                '/assets/pencil.svg'
                class=(scopedClass 'list-item-link-icon')
              }}
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
              {{inlineSvg
                '/assets/warning.svg'
                class=(scopedClass 'list-item-link-icon')
              }}
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
              {{inlineSvg
                '/assets/users.svg'
                class=(scopedClass 'list-item-link-icon')
              }}
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
              {{inlineSvg
                '/assets/bubble.svg'
                class=(scopedClass 'list-item-link-icon')
              }}
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
              {{inlineSvg
                '/assets/activity.svg'
                class=(scopedClass 'list-item-link-icon')
              }}

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
              {{inlineSvg
                '/assets/language.svg'
                class=(scopedClass 'list-item-link-icon')
              }}
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
              {{inlineSvg
                '/assets/file.svg'
                class=(scopedClass 'list-item-link-icon')
              }}
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
              {{inlineSvg
                '/assets/tag.svg'
                class=(scopedClass 'list-item-link-icon')
              }}
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
              {{inlineSvg
                '/assets/share.svg'
                class=(scopedClass 'list-item-link-icon')
              }}
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
            {{inlineSvg
              '/assets/gear.svg'
              class=(scopedClass 'list-item-link-icon')
            }}
            <span class='list-item-link-text'>
              {{t 'components.project_navigation.settings_link_title'}}
            </span>
          </LinkTo>
        </li>
      </div>
    </ul>
  </template>
}
