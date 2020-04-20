import Component from '@glimmer/component';
import {action} from '@ember/object';

interface Args {
  title: string;
  syncChecked: boolean;
  syncCheckLabel: string;
  onChangeSyncChecked: (checked: boolean) => void;
}

export default class DataControlCheckboxes extends Component<Args> {
  @action
  changeSyncChecked(event: Event) {
    const target = event.target as HTMLInputElement;

    this.args.onChangeSyncChecked(target.checked);
  }
}
