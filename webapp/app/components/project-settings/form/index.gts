import {service} from '@ember/service';
import {action} from '@ember/object';
import Component from '@glimmer/component';
import GlobalState from 'accent-webapp/services/global-state';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import IntlService from 'ember-intl/services/intl';
import {tracked} from '@glimmer/tracking';
import {get, fn, concat} from '@ember/helper';
import onKey from 'ember-keyboard/modifiers/on-key';
import {on} from '@ember/modifier';
import AccEmojiPicker from 'accent-webapp/components/acc-emoji-picker/index';
import ProjectLogo from 'accent-webapp/components/project-logo/index';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import {scopedClass} from 'ember-scoped-css';
import AsyncButton from 'accent-webapp/components/async-button/index';
import t from 'ember-intl/helpers/t';

interface Args {
  project: any;
  permissions: Record<string, true>;
  onUpdateProject: ({
    isFileOperationsLocked,
    name,
    mainColor,
    logo
  }: {
    isFileOperationsLocked: boolean;
    name: string;
    mainColor: string;
    logo: string;
  }) => Promise<any>;
}

export default class ProjectSettingsForm extends Component<Args> {
  <template>
    <div class='project-settings-form'>
      {{#if (get @permissions 'updateProject')}}
        <div class='field'>
          <input
            value={{this.name}}
            class='textInput'
            {{onKey 'cmd+Enter' (fn this.updateProject)}}
            {{on 'input' (fn this.setName)}}
          />

          <input
            type='color'
            value={{this.mainColor}}
            class='colorInput'
            {{on 'change' (fn this.setMainColor)}}
          />

          <div class='logo-field'>
            <AccEmojiPicker @onPicked={{fn this.logoPicked}} class='logo'>
              <ProjectLogo @logo={{this.logo}} />
            </AccEmojiPicker>

            {{#if this.logo}}
              <button class='logoReset' {{on 'click' (fn this.logoReset)}}>
                {{inlineSvg 'assets/x' class=(scopedClass 'logoReset-icon')}}
              </button>
            {{/if}}
          </div>
        </div>

        <AsyncButton
          @onClick={{fn this.updateProject}}
          @loading={{this.isUpdatingProject}}
          class='button button--filled'
        >
          {{t 'components.project_settings.form.update_button'}}
        </AsyncButton>
      {{/if}}

      {{#if (get @permissions 'lockProjectFileOperations')}}
        <div class='lock'>
          {{#if this.isFileOperationsLocked}}
            <div
              role='button'
              class='button lock-text lock-text--active'
              {{on 'click' (fn this.setLockedFileOperations)}}
            >
              {{inlineSvg
                'assets/lock--unlocked'
                class=(concat
                  (scopedClass 'lock-icon')
                  ' '
                  (scopedClass 'lock-icon--unlocked')
                )
              }}

              {{t
                'components.project_settings.form.lock_file_operations.remove_lock_button'
              }}
            </div>
          {{else}}
            <div
              role='button'
              class='button lock-text lock-text--inactive'
              {{on 'click' (fn this.setLockedFileOperations)}}
            >
              {{inlineSvg
                'assets/lock--locked'
                class=(concat
                  (scopedClass 'lock-icon')
                  ' '
                  (scopedClass 'lock-icon--locked')
                )
              }}

              {{t
                'components.project_settings.form.lock_file_operations.add_lock_button'
              }}
            </div>
          {{/if}}

          <p class='lock-text-helper'>
            {{t 'components.project_settings.form.lock_file_operations.text_1'}}
          </p>
        </div>
      {{/if}}
    </div>
  </template>
  @service('global-state')
  declare globalState: GlobalState;

  @service('flash-messages')
  declare flashMessages: FlashMessages;

  @service('intl')
  declare intl: IntlService;

  @tracked
  name = this.args.project.name;

  @tracked
  isUpdatingProject = false;

  @tracked
  mainColor = this.args.project.mainColor;

  @tracked
  logo = this.args.project.logo;

  @tracked
  isFileOperationsLocked = this.args.project.isFileOperationsLocked;

  @action
  logoPicked(selection: string) {
    this.logo = selection;
  }

  @action
  async setLockedFileOperations() {
    this.isUpdatingProject = true;
    this.isFileOperationsLocked = !this.isFileOperationsLocked;

    await this.args.onUpdateProject({
      isFileOperationsLocked: this.isFileOperationsLocked,
      name: this.name,
      mainColor: this.mainColor,
      logo: this.logo
    });

    this.isUpdatingProject = false;
  }

  @action
  async updateProject() {
    this.isUpdatingProject = true;

    await this.args.onUpdateProject({
      isFileOperationsLocked: this.isFileOperationsLocked,
      name: this.name,
      mainColor: this.mainColor,
      logo: this.logo
    });

    this.isUpdatingProject = false;
  }

  @action
  logoReset() {
    this.logo = null;
  }

  @action
  setName(event: Event) {
    const target = event.target as HTMLInputElement;

    this.name = target.value;
  }

  @action
  setMainColor(event: Event) {
    const target = event.target as HTMLInputElement;

    this.mainColor = target.value;

    this.globalState.mainColor = this.mainColor;
  }
}
