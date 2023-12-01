import {inject as service} from '@ember/service';
import Component from '@glimmer/component';
import {action} from '@ember/object';
import IntlService from 'ember-intl/services/intl';

interface Args {
  title: string;
  targetVersion: string;
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

  @action
  changeTargetVersion(targetVersion: string) {
    this.args.onChangeTargetVersion(targetVersion);
  }

  @action
  changeSpecificVersion(specificVersion: string) {
    this.args.onChangeSpecificVersion(specificVersion);
  }
}
