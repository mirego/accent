import {action} from '@ember/object';
import {inject as service} from '@ember/service';
import Component from '@glimmer/component';
import IntlService from 'ember-intl/services/intl';
import GlobalState from 'accent-webapp/services/global-state';
import {tracked} from '@glimmer/tracking';

interface Args {
  revisions: any;
  revision: any;
  withRevisionsCount: boolean;
  onSelect: (revision: any) => void;
}

export default class RevisionSelector extends Component<Args> {
  @service('intl')
  intl: IntlService;

  @service('global-state')
  globalState: GlobalState;

  @tracked
  withRevisionsCount = true;

  get hasManyRevisions() {
    return this.args.revisions && this.args.revisions.length > 1;
  }

  get revisionValue() {
    return this.mappedRevisions.find(
      ({value}: {value: string}) => value === this.args.revision
    );
  }

  get mappedRevisions() {
    return this.args.revisions.map(
      ({
        id,
        name,
        language,
      }: {
        id: string;
        name: string;
        language: any;
      }) => {
        const displayName = name || language.name;

        return {label: displayName, value: id};
      }
    );
  }

  get otherRevisionsCount() {
    return this.args.revisions && this.args.revisions.length - 1;
  }

  @action
  selectRevision({value}: any) {
    this.globalState.revision = value;

    this.args.onSelect(value);
  }
}
