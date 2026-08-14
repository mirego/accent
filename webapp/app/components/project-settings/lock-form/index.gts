import {action} from '@ember/object';
import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import {get, fn, concat} from '@ember/helper';
import {on} from '@ember/modifier';
import LockLockedSvg from 'accent-webapp/svgs/assets/lock--locked.svg';
import LockUnlockedSvg from 'accent-webapp/svgs/assets/lock--unlocked.svg';
import {scopedClass} from 'ember-scoped-css';
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

export default class ProjectSettingsLockForm extends Component<Args> {
  <template>
    {{#if (get @permissions 'lockProjectFileOperations')}}
      <div class='project-settings-lock-form'>
        {{#if this.isFileOperationsLocked}}
          <button
            type='button'
            class='button button--filled button--borderless button--green lock-text lock-text--active'
            {{on 'click' (fn this.setLockedFileOperations)}}
          >
            <LockUnlockedSvg
              class={{concat
                (scopedClass 'lock-icon')
                ' '
                (scopedClass 'lock-icon--unlocked')
              }}
            />

            {{t
              'components.project_settings.form.lock_file_operations.remove_lock_button'
            }}
          </button>
        {{else}}
          <button
            type='button'
            class='button button--filled button--borderless button--red lock-text lock-text--inactive'
            {{on 'click' (fn this.setLockedFileOperations)}}
          >
            <LockLockedSvg
              class={{concat
                (scopedClass 'lock-icon')
                ' '
                (scopedClass 'lock-icon--locked')
              }}
            />

            {{t
              'components.project_settings.form.lock_file_operations.add_lock_button'
            }}
          </button>
        {{/if}}

        <p class='lock-text-helper'>
          {{t 'components.project_settings.form.lock_file_operations.text_1'}}
        </p>
      </div>
    {{/if}}

    <style scoped>
      .project-settings-lock-form {
        display: flex;
        align-items: center;
        margin: 20px 0;
        gap: 5px;
      }

      .lock-text-helper {
        font-size: 11px;
        font-style: italic;
        color: #555;
      }

      div.lock-text {
        display: inline-flex;
        align-items: center;
        margin-right: 12px;
        font-size: 12px;
        font-weight: bold;
        cursor: pointer;
        padding: 3px 5px;
      }
      div.lock-text.lock-text--inactive {
        color: var(--color-gray);
      }
      div.lock-text.lock-text--inactive:hover {
        color: var(--color-green);
        border-color: var(--color-green);
      }
      div.lock-text.lock-text--inactive:hover .lock-icon {
        stroke: var(--color-green);
      }
      div.lock-text.lock-text--inactive .lock-icon {
        stroke: #aaa;
      }
      div.lock-text.lock-text--active {
        color: var(--color-error);
        border-color: var(--color-error);
      }
      div.lock-text.lock-text--active .lock-icon {
        stroke: var(--color-error);
      }

      .lock-icon {
        width: 15px;
        height: 15px;
        margin-right: 6px;
      }
    </style>
  </template>

  @tracked
  isUpdatingProject = false;

  @tracked
  isFileOperationsLocked = this.args.project.isFileOperationsLocked;

  @action
  async setLockedFileOperations() {
    this.isUpdatingProject = true;
    this.isFileOperationsLocked = !this.isFileOperationsLocked;

    await this.args.onUpdateProject({
      isFileOperationsLocked: this.isFileOperationsLocked,
      name: this.args.project.name,
      mainColor: this.args.project.mainColor,
      logo: this.args.project.logo
    });

    this.isUpdatingProject = false;
  }
}
