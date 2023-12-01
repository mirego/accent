import {inject as service} from '@ember/service';
import Component from '@glimmer/component';
import {action} from '@ember/object';
import {tracked} from '@glimmer/tracking';
import IntlService from 'ember-intl/services/intl';

interface Args {
  title: string;
  events: string[];
  onChangeTargetVersion: (targetVersion: string) => void;
  onChangeSpecificVersion: (specificVersion: string) => void;
}

export default class DataControlRadio extends Component<Args> {
  @service('intl')
  intl: IntlService;

  allTargetVersions = [
    {
      value: 'LATEST',
      label: 'components.project_settings.integrations.target_version.options.latest',
    },
    {
      value: 'SPECIFIC',
      label:
        'components.project_settings.integrations.target_version.options.specific',
    },
    {
      value: 'ALL',
      label:
        'components.project_settings.integrations.target_version.options.all',
    },
  ];

  @tracked
  targetVersion: string = this.allTargetVersions[0].value;
  specificVersion: string | null = null;

  // @action
  // changeTargetVersion(targetVersion: string) {
  //   this.targetVersion = targetVersion;
  //   this.args.onChangeTargetVersion(targetVersion);
  // }

  @action
  changeTargetVersion(targetVersion: string) {
    this.targetVersion = targetVersion;
    if (typeof this.args.onChangeTargetVersion === 'function') {
      this.args.onChangeTargetVersion(targetVersion);
    }
  }

  @action
  changeSpecificVersion(event: Event) {
    const target = event.target as HTMLInputElement;
    console.log("Changing specific version")
    this.args.onChangeSpecificVersion(target.value);
    console.log(this.specificVersion);
  }
}
