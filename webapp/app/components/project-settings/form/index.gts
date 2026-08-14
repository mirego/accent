import {service} from '@ember/service';
import {action} from '@ember/object';
import Component from '@glimmer/component';
import GlobalState from 'accent-webapp/services/global-state';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import IntlService from 'ember-intl/services/intl';
import {tracked} from '@glimmer/tracking';
import {get, fn} from '@ember/helper';
import onKey from 'ember-keyboard/modifiers/on-key';
import {on} from '@ember/modifier';
import AccEmojiPicker from 'accent-webapp/components/acc-emoji-picker/index';
import ProjectLogo from 'accent-webapp/components/project-logo/index';
import XSvg from 'accent-webapp/svgs/assets/x.svg';
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
        <label class='field'>
          <span class='label'>{{t
              'components.project_settings.form.name_label'
            }}</span>
          <input
            value={{this.name}}
            class='textInput'
            {{onKey 'cmd+Enter' (fn this.updateProject)}}
            {{on 'input' (fn this.setName)}}
          />
        </label>

        <label class='field'>
          <span class='label'>{{t
              'components.project_settings.form.main_color_label'
            }}</span>
          <input
            type='color'
            value={{this.mainColor}}
            class='colorInput'
            {{on 'change' (fn this.setMainColor)}}
          />
        </label>

        <div class='field'>
          <span class='label'>{{t
              'components.project_settings.form.logo_label'
            }}</span>
          <div class='logo-field'>
            <AccEmojiPicker @onPicked={{fn this.logoPicked}} class='logo'>
              <ProjectLogo @logo={{this.logo}} />
            </AccEmojiPicker>

            {{#if this.logo}}
              <button class='logoReset' {{on 'click' (fn this.logoReset)}}>
                <XSvg class={{scopedClass 'logoReset-icon'}} />
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
    </div>

    <style scoped>
      .colorInput,
      .textInput {
        transition: 0.2s ease-in-out;
        transition-property: background, border, box-shadow;
        resize: vertical;
        outline: 0;
        border-radius: var(--border-radius);
        border: 2px solid var(--input-border-color);
        background: var(--input-background);
        color: var(--input-color);
        font-family: var(--font-monospace);
        line-height: 1.4;
        max-height: 200px;
      }
      .colorInput::-moz-selection,
      .textInput::-moz-selection {
        background: color-mix(in srgb, var(--color-primary) 70%, transparent);
      }
      .colorInput::selection,
      .textInput::selection {
        background: color-mix(in srgb, var(--color-primary) 70%, transparent);
      }
      .colorInput:focus,
      .textInput:focus {
        border: 2px solid var(--color-primary);
      }
      .colorInput:disabled,
      .textInput:disabled {
        color: var(--color-grey);
        background: var(--background-light);
      }

      @media (hover: none) and (max-width: 640px) {
        .colorInput,
        .textInput {
          font-size: 16px !important;
        }
      }
      .project-settings-form {
        display: flex;
        flex-direction: column;
        gap: 10px;
        margin-top: 25px;
      }

      .textInput {
        max-width: 350px;
        width: 100%;
        padding: 10px;
        font-family: var(--font-primary);
        font-size: 12px;
      }

      .colorInput {
        width: 48px;
        height: 40px;
        padding: 5px 11px;
      }

      .field {
        display: flex;
        flex-direction: column;
        align-items: flex-start;
        gap: 4px;
      }

      .label {
        font-size: 11px;
        text-transform: uppercase;
        font-weight: bold;
        opacity: 0.7;
      }

      .logo {
        display: flex;
        width: 25px;
        height: 22px;
        padding: 0;
        font-size: 25px;
        line-height: 1;
        background: transparent;
        cursor: pointer;
      }
      .logo :global(svg) {
        width: 25px;
        height: 21px;
      }
      .logo :global(svg circle) {
        fill: var(--logo-background);
      }
      .logo :global(svg path) {
        fill: var(--logo-foreground);
      }
      .logo:hover {
        opacity: 0.6;
      }

      .logo-field {
        position: relative;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        padding: 0 10px;
        height: 40px;
        border-radius: var(--border-radius);
        border: 2px solid var(--input-border-color);
        background: var(--input-background);
      }

      .logoReset {
        position: absolute;
        top: -3px;
        right: -14px;
        padding: 0;
        background: none;
        color: #999;
      }
      .logoReset :global(svg) {
        width: 10px;
        height: 10px;
      }
      .logoReset:focus,
      .logoReset:hover {
        opacity: 0.6;
      }
    </style>
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

  @action
  logoPicked(selection: string) {
    this.logo = selection;
  }

  @action
  async updateProject() {
    this.isUpdatingProject = true;

    await this.args.onUpdateProject({
      isFileOperationsLocked: this.args.project.isFileOperationsLocked,
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
