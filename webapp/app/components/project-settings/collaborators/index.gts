import Component from '@glimmer/component';
import {get} from '@ember/helper';
import CreateForm from 'accent-webapp/components/project-settings/collaborators/create-form/index';
import List from 'accent-webapp/components/project-settings/collaborators/list/index';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
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
          <span class='rolesList-title'>
            {{inlineSvg 'assets/tool.svg' class=(scopedClass 'rolesList-icon')}}
            {{t 'general.roles.OWNER'}}
          </span>
          <p class='rolesList-text'>
            {{t 'components.project_settings.collaborators.owner_text'}}
          </p>

          <span class='rolesList-title'>
            {{inlineSvg
              'assets/users.svg'
              class=(scopedClass 'rolesList-icon')
            }}
            {{t 'general.roles.ADMIN'}}
          </span>
          <p class='rolesList-text'>
            {{t 'components.project_settings.collaborators.admin_text'}}
          </p>

          <span class='rolesList-title'>
            {{inlineSvg 'assets/code.svg' class=(scopedClass 'rolesList-icon')}}
            {{t 'general.roles.DEVELOPER'}}
          </span>
          <p class='rolesList-text'>
            {{t 'components.project_settings.collaborators.developer_text'}}
          </p>

          <span class='rolesList-title'>
            {{inlineSvg
              'assets/check.svg'
              class=(scopedClass 'rolesList-icon')
            }}
            {{t 'general.roles.REVIEWER'}}
          </span>
          <p class='rolesList-text'>
            {{t 'components.project_settings.collaborators.reviewer_text'}}
          </p>

          <span class='rolesList-title'>
            {{inlineSvg
              'assets/machine-translations.svg'
              class=(scopedClass 'rolesList-icon')
            }}
            {{t 'general.roles.TRANSLATOR'}}
          </span>
          <p class='rolesList-text'>
            {{t 'components.project_settings.collaborators.translator_text'}}
          </p>
        </div>
      </div>
    </div>
  </template>
}
