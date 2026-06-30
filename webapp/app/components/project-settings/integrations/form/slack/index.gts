import Component from '@glimmer/component';
import {action} from '@ember/object';
import DataControlText from 'accent-webapp/components/project-settings/integrations/form/data-control-text/index';
import fieldError from 'accent-webapp/helpers/field-error';
import t from 'ember-intl/helpers/t';
import DataControlCheckboxes from 'accent-webapp/components/project-settings/integrations/form/data-control-checkboxes/index';

interface Args {
  errors: any;
  url: any;
  project: any;
  events: any;
  onChangeUrl: (url: string) => void;
  onChangeEventsChecked: (events: string[]) => void;
}

export default class Slack extends Component<Args> {
  <template>
    <DataControlText
      @error={{fieldError @errors 'data.url'}}
      @label={{t 'components.project_settings.integrations.data.url'}}
      @placeholder={{'https://hooks.slack.com/services/aaaa/bbbb/cccc'}}
      @value={{@url}}
      @onChange={{this.changeUrl}}
      @helpLinkHref={{'https://api.slack.com/incoming-webhooks'}}
      @helpLinkTitle={{t
        'components.project_settings.integrations.webhook_url_how'
      }}
    />

    <DataControlCheckboxes
      @title={{t 'components.project_settings.integrations.events.title'}}
      @events={{@events}}
      @onChangeEventsChecked={{@onChangeEventsChecked}}
    />
  </template>
  @action
  changeUrl(event: Event) {
    const target = event.target as HTMLInputElement;

    this.args.onChangeUrl(target.value);
  }
}
