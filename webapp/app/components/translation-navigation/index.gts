import Component from '@glimmer/component';
import {get, array} from '@ember/helper';
import {LinkTo} from '@ember/routing';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import {scopedClass} from 'ember-scoped-css';
import t from 'ember-intl/helpers/t';

interface Args {
  project: any;
  permissions: Record<string, true>;
  translation: any;
}

export default class TranslationNavigation extends Component<Args> {
  <template>
    <div class='navigation navigation--alt'>
      <ul class='navigation-list'>
        {{#if (get @permissions 'showProject')}}
          <li class='navigation-list-item'>
            <LinkTo
              @route='logged-in.project.translation.index'
              @models={{array @project.id @translation.id}}
              class='navigation-list-item-link'
            >
              {{inlineSvg
                'assets/pencil.svg'
                class=(scopedClass 'navigation-list-item-link-icon')
              }}
              <span class='navigation-list-item-link-text'>
                {{t 'components.translation_navigation.edit_link_title'}}
              </span>
            </LinkTo>
          </li>
        {{/if}}

        {{#if (get @permissions 'indexComments')}}
          <li class='navigation-list-item'>
            <LinkTo
              @route='logged-in.project.translation.comments'
              @models={{array @project.id @translation.id}}
              class='navigation-list-item-link'
            >
              {{inlineSvg
                'assets/bubble.svg'
                class=(scopedClass 'navigation-list-item-link-icon')
              }}
              <span class='navigation-list-item-link-text'>
                {{#if @translation.commentsCount}}
                  {{t
                    'components.translation_navigation.comments_link_title'
                    count=@translation.commentsCount
                  }}
                {{else}}
                  {{t
                    'components.translation_navigation.comments_link_title'
                    count=0
                  }}
                {{/if}}
              </span>
            </LinkTo>
          </li>
        {{/if}}

        {{#if (get @permissions 'indexTranslationActivities')}}
          <li class='navigation-list-item'>
            <LinkTo
              @route='logged-in.project.translation.activities'
              @models={{array @project.id @translation.id}}
              class='navigation-list-item-link'
            >
              {{inlineSvg
                'assets/activity.svg'
                class=(scopedClass 'navigation-list-item-link-icon')
              }}
              <span class='navigation-list-item-link-text'>
                {{t 'components.translation_navigation.activities_link_title'}}
              </span>
            </LinkTo>
          </li>
        {{/if}}

        {{#if (get @permissions 'indexTranslationEditions')}}
          <li class='navigation-list-item'>
            <LinkTo
              @route='logged-in.project.translation.editions'
              @models={{array @project.id @translation.id}}
              class='navigation-list-item-link'
            >
              {{inlineSvg
                'assets/tag.svg'
                class=(scopedClass 'navigation-list-item-link-icon')
              }}
              <span class='navigation-list-item-link-text'>
                {{t 'components.translation_navigation.editions_link_title'}}
              </span>
            </LinkTo>
          </li>
        {{/if}}

        {{#if (get @permissions 'updateTranslationSettings')}}
          <li class='navigation-list-item navigation-list-item--last'>
            <LinkTo
              @route='logged-in.project.translation.settings'
              @models={{array @project.id @translation.id}}
              class='navigation-list-item-link'
            >
              {{inlineSvg
                'assets/gear.svg'
                class=(scopedClass 'navigation-list-item-link-icon')
              }}
            </LinkTo>
          </li>
        {{/if}}
      </ul>
    </div>
  </template>
}
