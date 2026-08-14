import Component from '@glimmer/component';
import {get, array} from '@ember/helper';
import {LinkTo} from '@ember/routing';
import ActivitySvg from 'accent-webapp/svgs/assets/activity.svg';
import BubbleSvg from 'accent-webapp/svgs/assets/bubble.svg';
import GearSvg from 'accent-webapp/svgs/assets/gear.svg';
import PencilSvg from 'accent-webapp/svgs/assets/pencil.svg';
import TagSvg from 'accent-webapp/svgs/assets/tag.svg';
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
              <PencilSvg
                class={{scopedClass 'navigation-list-item-link-icon'}}
              />
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
              <BubbleSvg
                class={{scopedClass 'navigation-list-item-link-icon'}}
              />
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
              <ActivitySvg
                class={{scopedClass 'navigation-list-item-link-icon'}}
              />
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
              <TagSvg class={{scopedClass 'navigation-list-item-link-icon'}} />
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
              <GearSvg class={{scopedClass 'navigation-list-item-link-icon'}} />
            </LinkTo>
          </li>
        {{/if}}
      </ul>
    </div>

    <style scoped>
      .navigation--alt .navigation-list-item {
        margin-right: 3px;
      }
      .navigation--alt .navigation-list-item-link {
        padding: 4px 11px 4px 10px;
        border-radius: var(--border-radius);
        opacity: 0.9;
      }
      .navigation--alt .navigation-list-item-link:global(.active) {
        color: var(--color-primary);
        opacity: 1;
      }

      .navigation-list {
        display: flex;
        align-items: stretch;
        gap: 10px;
        z-index: 10;
        padding: 4px;
        margin-bottom: 20px;
        border-bottom: 2px solid var(--content-background-border);
      }

      .navigation-list-item {
        margin-right: 16px;
      }
      .navigation-list-item:last-of-type {
        margin-right: 0;
      }

      .navigation-list-item--last {
        margin-left: auto;
      }

      .navigation-list-item-link {
        transition: 0.2s ease-in-out;
        transition-property: color, border-color, background;
        display: flex;
        align-items: center;
        gap: 7px;
        height: 100%;
        position: relative;
        text-decoration: none;
        font-size: 14px;
        font-weight: 500;
        color: var(--color-black);
      }
      .navigation-list-item-link:focus .navigation-list-item-link-text,
      .navigation-list-item-link:hover .navigation-list-item-link-text,
      .navigation-list-item-link:global(.active)
        .navigation-list-item-link-text {
        opacity: 0.9;
      }
      .navigation-list-item-link:focus .navigation-list-item-link-icon,
      .navigation-list-item-link:hover .navigation-list-item-link-icon,
      .navigation-list-item-link:global(.active)
        .navigation-list-item-link-icon {
        stroke: currentColor;
      }

      .navigation-list-item-link-text {
        opacity: 0.7;
        transition: 0.2s ease-in-out;
        transition-property: opacity;
      }

      .navigation-list-item-link-icon {
        transition: 0.2s ease-in-out;
        transition-property: stroke;
        width: 14px;
        height: 14px;
        opacity: 0.8;
        stroke: var(--color-black);
      }

      @media (max-width: 640px) {
        .navigation-list {
          justify-content: space-between;
        }
        .navigation-list-item-link {
          flex-direction: column;
          font-size: 12px;
          text-align: center;
        }
        .navigation-list-item-link-icon {
          margin-right: 0;
          margin-bottom: 5px;
        }
      }
      @media (max-width: 440px) {
        .navigation-list-item {
          width: 100%;
          margin-right: 0;
        }
        .navigation-list-item-link-text {
          display: none;
        }
        .navigation--alt .navigation-list-item-link {
          padding: 8px 15px 5px 15px;
        }
      }
    </style>
  </template>
}
