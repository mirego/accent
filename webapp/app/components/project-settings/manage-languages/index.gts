import Component from '@glimmer/component';
import Overview from 'accent-webapp/components/project-settings/manage-languages/overview/index';
import {get} from '@ember/helper';
import CreateForm from 'accent-webapp/components/project-settings/manage-languages/create-form/index';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import t from 'ember-intl/helpers/t';

interface Args {
  project: any;
  revisions: any;
  permissions: Record<string, true>;
  languages: any;
  errors: any;
  onPromoteMaster: () => void;
  onDelete: () => void;
  onCreate: () => void;
}

export default class ManageLanguages extends Component<Args> {
  <template>
    <div class='project-settings-manage-languages'>
      <div class='overview'>
        <Overview
          @permissions={{@permissions}}
          @project={{@project}}
          @revisions={{@revisions}}
          @onPromoteMaster={{@onPromoteMaster}}
          @onDelete={{@onDelete}}
        />

        {{#if (get @permissions 'createSlave')}}
          <div class='createSlaveForm'>
            {{#if @errors}}
              <ul class='error'>
                {{#each @errors as |error|}}
                  <li>
                    {{error}}
                  </li>
                {{/each}}
              </ul>
            {{/if}}
            <CreateForm
              @permissions={{@permissions}}
              @project={{@project}}
              @languages={{@languages}}
              @onCreate={{@onCreate}}
            />
          </div>
        {{/if}}
      </div>

      <div class='help'>
        <h2 class='titleText'>
          {{inlineSvg '/assets/sync.svg' class='button-icon'}}
          {{t 'components.project_manage_languages.sync_explain_title'}}
        </h2>

        <p class='explainText'>
          {{t 'components.project_manage_languages.sync_explain_text'}}
        </p>

        <h2 class='titleText'>
          {{inlineSvg '/assets/merge.svg' class='button-icon'}}
          {{t
            'components.project_manage_languages.add_translations_explain_title'
          }}
        </h2>

        <p class='explainText'>
          {{t
            'components.project_manage_languages.add_translations_explain_text'
          }}
        </p>

        <h2 class='titleText'>
          {{inlineSvg '/assets/check.svg' class='button-icon'}}
          {{t 'components.project_manage_languages.conflicts_explain_title'}}
        </h2>

        <p class='explainText'>
          {{t 'components.project_manage_languages.conflicts_explain_text'}}
        </p>
      </div>
    </div>
  </template>
}
