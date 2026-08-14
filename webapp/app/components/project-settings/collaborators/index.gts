import Component from '@glimmer/component';
import {get} from '@ember/helper';
import CreateForm from 'accent-webapp/components/project-settings/collaborators/create-form/index';
import List from 'accent-webapp/components/project-settings/collaborators/list/index';
import CheckSvg from 'accent-webapp/svgs/assets/check.svg';
import CodeSvg from 'accent-webapp/svgs/assets/code.svg';
import MachineTranslationsSvg from 'accent-webapp/svgs/assets/machine-translations.svg';
import ToolSvg from 'accent-webapp/svgs/assets/tool.svg';
import UsersSvg from 'accent-webapp/svgs/assets/users.svg';
import {scopedClass} from 'ember-scoped-css';
import t from 'ember-intl/helpers/t';

interface Args {
  project: any;
  permissions: Record<string, true>;
  collaborators: any;
  onCreateCollaborator: () => void;
  onUpdateCollaborator: () => void;
  onDeleteCollaborator: () => void;
}

export default class Collaborators extends Component<Args> {
  <template>
    <div class='project-settings-collaborators'>
      <div class='columns'>
        <div class='columns-item'>
          {{#if (get @permissions 'createCollaborator')}}
            <div class='createForm'>
              <CreateForm
                @project={{@project}}
                @onCreate={{@onCreateCollaborator}}
              />
            </div>
          {{/if}}

          <List
            @permissions={{@permissions}}
            @collaborators={{@collaborators}}
            @onDelete={{@onDeleteCollaborator}}
            @onUpdate={{@onUpdateCollaborator}}
          />
        </div>

        <div class='columns-item rolesList'>
          <h3 class='rolesList-heading'>
            {{t 'components.project_settings.collaborators.roles_title'}}
          </h3>

          <div class='roleCard roleCard--owner'>
            <span class='roleCard-icon'>
              <ToolSvg class={{scopedClass 'roleCard-iconSvg'}} />
            </span>
            <div class='roleCard-body'>
              <span class='roleCard-name'>
                {{t 'general.roles.OWNER'}}
                <span class='roleCard-rank'>
                  {{t 'components.project_settings.collaborators.rank_full'}}
                </span>
              </span>
              <p class='roleCard-text'>
                {{t 'components.project_settings.collaborators.owner_text'}}
              </p>
            </div>
          </div>

          <div class='roleCard'>
            <span class='roleCard-icon'>
              <UsersSvg class={{scopedClass 'roleCard-iconSvg'}} />
            </span>
            <div class='roleCard-body'>
              <span class='roleCard-name'>
                {{t 'general.roles.ADMIN'}}
              </span>
              <p class='roleCard-text'>
                {{t 'components.project_settings.collaborators.admin_text'}}
              </p>
            </div>
          </div>

          <div class='roleCard'>
            <span class='roleCard-icon'>
              <CodeSvg class={{scopedClass 'roleCard-iconSvg'}} />
            </span>
            <div class='roleCard-body'>
              <span class='roleCard-name'>
                {{t 'general.roles.DEVELOPER'}}
              </span>
              <p class='roleCard-text'>
                {{t 'components.project_settings.collaborators.developer_text'}}
              </p>
            </div>
          </div>

          <div class='roleCard'>
            <span class='roleCard-icon'>
              <CheckSvg class={{scopedClass 'roleCard-iconSvg'}} />
            </span>
            <div class='roleCard-body'>
              <span class='roleCard-name'>
                {{t 'general.roles.REVIEWER'}}
              </span>
              <p class='roleCard-text'>
                {{t 'components.project_settings.collaborators.reviewer_text'}}
              </p>
            </div>
          </div>

          <div class='roleCard roleCard--translator'>
            <span class='roleCard-icon'>
              <MachineTranslationsSvg
                class={{scopedClass 'roleCard-iconSvg'}}
              />
            </span>
            <div class='roleCard-body'>
              <span class='roleCard-name'>
                {{t 'general.roles.TRANSLATOR'}}
              </span>
              <p class='roleCard-text'>
                {{t
                  'components.project_settings.collaborators.translator_text'
                }}
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <style scoped>
      .project-settings-collaborators {
        position: relative;
        margin-top: 30px;
      }

      .createForm {
        margin: 0 0 10px 0;
      }

      .columns {
        display: flex;
        align-items: flex-start;
        justify-content: space-between;
        margin-top: 20px;
      }

      .columns-item:first-of-type {
        flex: 1 0 65%;
        margin-right: 25px;
      }

      .columns-item:last-of-type {
        flex: 1 1 100%;
      }

      .rolesList {
        display: flex;
        flex-direction: column;
        gap: 8px;
      }

      .rolesList-heading {
        margin: 0 0 4px;
        font-size: 11px;
        font-weight: 700;
        letter-spacing: 0.06em;
        text-transform: uppercase;
        color: color-mix(in srgb, var(--text-color-normal) 50%, transparent);
      }

      .roleCard {
        display: flex;
        gap: 12px;
        align-items: flex-start;
        margin-bottom: 12px;
      }

      .roleCard-icon {
        display: inline-flex;
        flex-shrink: 0;
        align-items: center;
        justify-content: center;
        box-sizing: content-box;
        width: 16px;
        height: 16px;
        padding: 8px;
        border-radius: var(--border-radius);
        color: var(--color-primary);
        background: color-mix(in srgb, var(--color-primary) 12%, transparent);
      }
      .roleCard-iconSvg {
        width: 16px;
        height: 16px;
        stroke: var(--color-primary);
      }

      .roleCard-body {
        display: flex;
        flex-direction: column;
        gap: 3px;
      }

      .roleCard-name {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 13px;
        font-weight: 700;
        color: var(--text-color-normal);
      }

      .roleCard-rank {
        padding: 1px 7px;
        border-radius: 999px;
        font-size: 10px;
        font-weight: 600;
        letter-spacing: 0.03em;
        text-transform: uppercase;
        color: var(--color-primary);
        background: color-mix(in srgb, var(--color-primary) 14%, transparent);
      }
      .roleCard--translator .roleCard-rank {
        color: color-mix(in srgb, var(--text-color-normal) 55%, transparent);
        background: color-mix(
          in srgb,
          var(--text-color-normal) 10%,
          transparent
        );
      }

      .roleCard-text {
        margin: 0;
        font-size: 12px;
        line-height: 1.5;
        color: color-mix(in srgb, var(--text-color-normal) 65%, transparent);
      }

      @media (max-width: 800px) {
        .rolesList {
          display: none;
        }
      }
    </style>
  </template>
}
