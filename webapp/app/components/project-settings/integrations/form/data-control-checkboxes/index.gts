import {service} from '@ember/service';
import Component from '@glimmer/component';
import {action} from '@ember/object';
import {tracked} from '@glimmer/tracking';
import IntlService from 'ember-intl/services/intl';
import {Input} from '@ember/component';
import arrayIncludes from 'accent-webapp/helpers/array-includes';
import {on} from '@ember/modifier';
import {fn} from '@ember/helper';
import t from 'ember-intl/helpers/t';

interface Args {
  title: string;
  events: string[];
  onChangeEventsChecked: (events: string[]) => void;
}

export default class DataControlCheckboxes extends Component<Args> {
  <template>
    <div class='data-control'>
      <h3 class='data-title'>
        {{@title}}
      </h3>

      {{#each this.allEvents as |event|}}
        <label class='checkbox'>
          <Input
            @type='checkbox'
            @checked={{if (arrayIncludes @events event.value) 'checked'}}
            {{on 'change' (fn this.changeEventChecked event.value)}}
          />
          {{t event.label}}
        </label>
      {{/each}}
    </div>
  </template>
  @service('intl')
  declare intl: IntlService;

  allEvents = [
    {
      value: 'SYNC',
      label: 'components.project_settings.integrations.events.options.sync'
    },
    {
      value: 'NEW_CONFLICTS',
      label:
        'components.project_settings.integrations.events.options.new_conflicts'
    },
    {
      value: 'COMPLETE_REVIEW',
      label:
        'components.project_settings.integrations.events.options.complete_review'
    },
    {
      value: 'INTEGRATION_EXECUTE_AZURE_STORAGE_CONTAINER',
      label:
        'components.project_settings.integrations.events.options.integration_execute_azure_storage_container'
    },
    {
      value: 'INTEGRATION_EXECUTE_AWS_S3',
      label:
        'components.project_settings.integrations.events.options.integration_execute_aws_s3'
    }
  ];

  @tracked
  selectedEvents: Set<string> = new Set(this.args.events);

  @action
  changeEventChecked(event: string) {
    if (this.selectedEvents.has(event)) {
      this.selectedEvents.delete(event);
    } else {
      this.selectedEvents.add(event);
    }

    this.args.onChangeEventsChecked(Array.from(this.selectedEvents));
  }
}
