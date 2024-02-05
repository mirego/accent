import {inject as service} from '@ember/service';
import Component from '@glimmer/component';
import {action} from '@ember/object';
import {tracked} from '@glimmer/tracking';
import IntlService from 'ember-intl/services/intl';

interface Args {
  title: string;
  events: string[];
  onChangeEventsChecked: (events: string[]) => void;
}

export default class DataControlCheckboxes extends Component<Args> {
  @service('intl')
  intl: IntlService;

  allEvents = [
    {
      value: 'SYNC',
      label: 'components.project_settings.integrations.events.options.sync',
    },
    {
      value: 'NEW_CONFLICTS',
      label:
        'components.project_settings.integrations.events.options.new_conflicts',
    },
    {
      value: 'COMPLETE_REVIEW',
      label:
        'components.project_settings.integrations.events.options.complete_review',
    },
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
