import Component from '@glimmer/component';
import {service} from '@ember/service';
import {action} from '@ember/object';
import IntlService from 'ember-intl/services/intl';
import t from 'ember-intl/helpers/t';
import AsyncButton from 'accent-webapp/components/async-button/index';
import {fn} from '@ember/helper';

interface Args {
  project: any;
  onSubmit: () => void;
}

export default class DeleteForm extends Component<Args> {
  <template>
    <div class='project-settings-delete-form'>
      <strong class='title'>
        {{t 'components.project_settings.delete_form.title'}}
      </strong>

      <div class='zone'>
        <div class='zone-item'>
          <strong class='zone-title'>
            {{t 'components.project_settings.delete_form.delete_project_title'}}
          </strong>

          <div class='zone-content'>
            <p class='zone-text'>
              {{t
                'components.project_settings.delete_form.delete_project_text'
              }}
            </p>

            <AsyncButton
              @onClick={{fn this.deleteProject}}
              class='button button--filled button--red'
            >
              {{t
                'components.project_settings.delete_form.delete_project_button'
              }}
            </AsyncButton>
          </div>
        </div>
      </div>
    </div>

    <style scoped>
      .project-settings-delete-form {
        margin-top: 90px;
      }

      .title {
        display: block;
        width: 100%;
        padding-bottom: 6px;
        border-bottom: 1px solid var(--content-background-border);
        font-size: 19px;
        color: var(--color-error);
      }

      .zone {
        margin-top: 12px;
        padding: 10px;
        border-radius: var(--border-radius);
        background: var(--background-light);
        color: var(--color-error);
      }

      .zone-content {
        display: flex;
        align-items: center;
        justify-content: space-between;
      }

      .zone-title {
        font-size: 13px;
      }

      .zone-text {
        font-size: 12px;
        font-style: italic;
        opacity: 0.5;
      }
    </style>
  </template>
  @service('intl')
  declare intl: IntlService;

  @action
  deleteProject() {
    const message = this.intl.t(
      'components.project_settings.delete_form.delete_project_confirm'
    );

    // eslint-disable-next-line no-alert
    if (!window.confirm(message)) {
      return;
    }

    this.args.onSubmit();
  }
}
