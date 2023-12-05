import {inject as service} from '@ember/service';
import Component from '@glimmer/component';
import {action} from '@ember/object';
import IntlService from 'ember-intl/services/intl';

interface Args {
  onChangeTargetVersion: (targetVersion: string) => void;
  onChangeSpecificVersion: (specificVersion: string) => void;
}

export default class DataControlRadio extends Component<Args> {
  @service('intl')
  intl: IntlService;

  @action
  changeTargetVersion(targetVersion: string) {
    this.args.onChangeTargetVersion(targetVersion);
  }

  @action
  changeSpecificVersion(specificVersion: string) {
    this.args.onChangeSpecificVersion(specificVersion);
  }
}
