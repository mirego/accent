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
