import Component from '@glimmer/component';
import {LinkTo} from '@ember/routing';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
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
          {{inlineSvg
            'assets/code.svg'
            class=(concat
              (scopedClass 'link-icon') ' ' (scopedClass 'link-icon--api-token')
            )
          }}
          <strong>{{t
              'components.project_settings.links_list.api_token'
            }}</strong>
          <p>{{t 'components.project_settings.links_list.api_token_text'}}</p>
        </LinkTo>

        <LinkTo @route='logged-in.project.edit.cli' class='link'>
          {{inlineSvg
            'assets/terminal.svg'
            class=(concat
              (scopedClass 'link-icon') ' ' (scopedClass 'link-icon--cli')
            )
          }}
          <strong>{{t 'components.project_settings.links_list.cli'}}</strong>
          <p>{{t 'components.project_settings.links_list.cli_text'}}</p>
        </LinkTo>

        <LinkTo @route='logged-in.project.edit.badges' class='link'>
          {{inlineSvg
            'assets/badge.svg'
            class=(concat
              (scopedClass 'link-icon') ' ' (scopedClass 'link-icon--badges')
            )
          }}
          <strong>{{t 'components.project_settings.links_list.badges'}}</strong>
          <p>{{t 'components.project_settings.links_list.badges_text'}}</p>
        </LinkTo>

        <LinkTo @route='logged-in.project.edit.jipt' class='link'>
          {{inlineSvg
            'assets/edit-in-place.svg'
            class=(concat
              (scopedClass 'link-icon') ' ' (scopedClass 'link-icon--jipt')
            )
          }}
          <strong>{{t 'components.project_settings.links_list.jipt'}}</strong>
          <p>{{t 'components.project_settings.links_list.jipt_text'}}</p>
        </LinkTo>

        {{#if (get @permissions 'saveProjectMachineTranslationsConfig')}}
          <LinkTo
            @route='logged-in.project.edit.machine-translations'
            class='link'
          >
            {{inlineSvg
              'assets/rocket.svg'
              class=(concat
                (scopedClass 'link-icon')
                ' '
                (scopedClass 'link-icon--machine-translations')
              )
            }}
            <strong>{{t
                'components.project_settings.links_list.machine_translations'
              }}</strong>
            <p>{{t
                'components.project_settings.links_list.machine_translations_text'
              }}</p>

            {{#if (get @permissions 'machineTranslationsTranslate')}}
              <span class='link-check'>
                {{inlineSvg
                  'assets/check.svg'
                  class=(scopedClass 'link-check-icon')
                }}
              </span>
            {{/if}}
          </LinkTo>
        {{/if}}

        {{#if (get @permissions 'saveProjectPromptConfig')}}
          <LinkTo @route='logged-in.project.edit.prompts' class='link'>
            {{inlineSvg
              'assets/sparkle.svg'
              class=(concat
                (scopedClass 'link-icon') ' ' (scopedClass 'link-icon--prompts')
              )
            }}
            <strong>{{t
                'components.project_settings.links_list.prompts'
              }}</strong>
            <p>{{t 'components.project_settings.links_list.prompts_text'}}</p>

            {{#if (get @permissions 'usePromptImproveText')}}
              <span class='link-check'>
                {{inlineSvg
                  'assets/check.svg'
                  class=(scopedClass 'link-check-icon')
                }}
              </span>
            {{/if}}
          </LinkTo>
        {{/if}}

        {{#if (get @permissions 'indexLintEntries')}}
          <LinkTo @route='logged-in.project.edit.lint-entries' class='link'>
            {{inlineSvg
              'assets/warning.svg'
              class=(concat
                (scopedClass 'link-icon')
                ' '
                (scopedClass 'link-icon--lint-entries')
              )
            }}
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
  </template>
}
