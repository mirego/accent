import Component from '@glimmer/component';
import {LinkTo} from '@ember/routing';
import BadgeSvg from 'accent-webapp/svgs/assets/badge.svg';
import CheckSvg from 'accent-webapp/svgs/assets/check.svg';
import CodeSvg from 'accent-webapp/svgs/assets/code.svg';
import EditInPlaceSvg from 'accent-webapp/svgs/assets/edit-in-place.svg';
import RocketSvg from 'accent-webapp/svgs/assets/rocket.svg';
import SparkleSvg from 'accent-webapp/svgs/assets/sparkle.svg';
import TerminalSvg from 'accent-webapp/svgs/assets/terminal.svg';
import WarningSvg from 'accent-webapp/svgs/assets/warning.svg';
import {concat, get} from '@ember/helper';
import {scopedClass} from 'ember-scoped-css';
import t from 'ember-intl/helpers/t';

interface Args {
  project: any;
  permissions: Record<string, true>;
}

export default class LinksList extends Component<Args> {
  <template>
    <div class='project-settings-links-list'>
      <div class='list'>
        <LinkTo @route='logged-in.project.edit.api-token' class='link'>
          <CodeSvg
            class={{concat
              (scopedClass 'link-icon')
              ' '
              (scopedClass 'link-icon--api-token')
            }}
          />
          <strong>{{t
              'components.project_settings.links_list.api_token'
            }}</strong>
          <p>{{t 'components.project_settings.links_list.api_token_text'}}</p>
        </LinkTo>

        <LinkTo @route='logged-in.project.edit.cli' class='link'>
          <TerminalSvg
            class={{concat
              (scopedClass 'link-icon')
              ' '
              (scopedClass 'link-icon--cli')
            }}
          />
          <strong>{{t 'components.project_settings.links_list.cli'}}</strong>
          <p>{{t 'components.project_settings.links_list.cli_text'}}</p>
        </LinkTo>

        <LinkTo @route='logged-in.project.edit.badges' class='link'>
          <BadgeSvg
            class={{concat
              (scopedClass 'link-icon')
              ' '
              (scopedClass 'link-icon--badges')
            }}
          />
          <strong>{{t 'components.project_settings.links_list.badges'}}</strong>
          <p>{{t 'components.project_settings.links_list.badges_text'}}</p>
        </LinkTo>

        <LinkTo @route='logged-in.project.edit.jipt' class='link'>
          <EditInPlaceSvg
            class={{concat
              (scopedClass 'link-icon')
              ' '
              (scopedClass 'link-icon--jipt')
            }}
          />
          <strong>{{t 'components.project_settings.links_list.jipt'}}</strong>
          <p>{{t 'components.project_settings.links_list.jipt_text'}}</p>
        </LinkTo>

        {{#if (get @permissions 'saveProjectMachineTranslationsConfig')}}
          <LinkTo
            @route='logged-in.project.edit.machine-translations'
            class='link'
          >
            <RocketSvg
              class={{concat
                (scopedClass 'link-icon')
                ' '
                (scopedClass 'link-icon--machine-translations')
              }}
            />
            <strong>{{t
                'components.project_settings.links_list.machine_translations'
              }}</strong>
            <p>{{t
                'components.project_settings.links_list.machine_translations_text'
              }}</p>

            {{#if (get @permissions 'machineTranslationsTranslate')}}
              <span class='link-check'>
                <CheckSvg class={{scopedClass 'link-check-icon'}} />
              </span>
            {{/if}}
          </LinkTo>
        {{/if}}

        {{#if (get @permissions 'saveProjectPromptConfig')}}
          <LinkTo @route='logged-in.project.edit.prompts' class='link'>
            <SparkleSvg
              class={{concat
                (scopedClass 'link-icon')
                ' '
                (scopedClass 'link-icon--prompts')
              }}
            />
            <strong>{{t
                'components.project_settings.links_list.prompts'
              }}</strong>
            <p>{{t 'components.project_settings.links_list.prompts_text'}}</p>

            {{#if (get @permissions 'usePromptImproveText')}}
              <span class='link-check'>
                <CheckSvg class={{scopedClass 'link-check-icon'}} />
              </span>
            {{/if}}
          </LinkTo>
        {{/if}}

        {{#if (get @permissions 'indexLintEntries')}}
          <LinkTo @route='logged-in.project.edit.lint-entries' class='link'>
            <WarningSvg
              class={{concat
                (scopedClass 'link-icon')
                ' '
                (scopedClass 'link-icon--lint-entries')
              }}
            />
            <strong>{{t
                'components.project_settings.links_list.lint_entries'
              }}</strong>
            <p>{{t
                'components.project_settings.links_list.lint_entries_text'
              }}</p>
          </LinkTo>
        {{/if}}
      </div>
    </div>

    <style scoped>
      .project-settings-links-list {
        margin-top: 20px;
      }

      .list {
        display: flex;
        flex-wrap: wrap;
        align-items: flex-start;
      }

      .link {
        position: relative;
        display: flex;
        align-items: flex-start;
        justify-content: flex-start;
        flex-direction: column;
        margin: 0 30px 30px 0;
        max-width: 275px;
        background: var(--content-background);
        border-radius: var(--border-radius);
        color: var(--color-black);
        box-shadow:
          0 1px 4px var(--shadow-color),
          0 9px 19px var(--shadow-color);
        text-decoration: none;
        font-weight: 600;
        font-size: 13px;
        transition: 0.2s ease-in-out;
        transition-property: background, box-shadow, color;
        overflow: hidden;
      }
      .link strong {
        padding: 10px 20px 5px;
      }
      .link p {
        display: block;
        width: 100%;
        padding: 10px 20px 10px 19px;
        margin-top: 10px;
        font-size: 11px;
        font-weight: 400;
        border-top: 1px solid var(--content-background-border);
        color: var(--color-grey);
        background: var(--background-light);
        transition: 0.2s ease-in-out;
        transition-property: color;
      }
      .link:focus,
      .link:hover {
        color: var(--color-primary);
        box-shadow:
          0 3px 8px var(--shadow-color),
          0 9px 12px var(--shadow-color);
      }
      .link:focus .link-check,
      .link:hover .link-check {
        color: var(--color-primary);
      }

      .link-check-icon {
        width: 14px;
        height: 14px;
      }

      .link-check-text {
        font-size: 11px;
      }

      .link-check {
        position: absolute;
        top: 7px;
        right: 7px;
        height: 26px;
        width: 26px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 50px;
        color: var(--color-primary);
        background: color-mix(in srgb, var(--color-primary) 10%, transparent);
      }

      .link-icon {
        width: 30px;
        height: 30px;
        margin: 20px 17px 0;
        transition: 0.2s ease-in-out;
        transition-property: stroke;
        opacity: 0.8;
        stroke: var(--color-black);
        transition: 0.2s ease-in-out;
        transition-property: stroke;
      }
      .link-icon.link-icon--prompts path:global(:nth-child(3)),
      .link-icon.link-icon--machine-translations path:global(:nth-child(2)),
      .link-icon.link-icon--jipt path:global(:nth-child(2)),
      .link-icon.link-icon--cli path,
      .link-icon.link-icon--integrations circle:global(:nth-child(3)),
      .link-icon.link-icon--badges path:global(:nth-child(2)) {
        stroke: var(--color-primary);
      }

      @media (max-width: 640px) {
        .project-settings-links-list,
        .list {
          margin: 0;
        }
        .link {
          width: 100%;
          min-width: 0;
          max-width: none;
          margin: 0 0 20px;
        }
      }
    </style>
  </template>
}
