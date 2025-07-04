import {action} from '@ember/object';
import {service} from '@ember/service';
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
  declare intl: IntlService;

  @service('global-state')
  declare globalState: GlobalState;

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

  get revision() {
    return this.args.revisions.find(({id}: {id: string}) => {
      return id === this.args.revision;
    });
  }

  get masterRevision() {
    return this.args.revisions.find(({isMaster}: {isMaster: boolean}) => {
      return isMaster;
    });
  }

  get revisionName() {
    return this.revision.name || this.revision.language.name;
  }

  get masterRevisionName() {
    return this.masterRevision.name || this.masterRevision.language.name;
  }

  get mappedRevisions() {
    return this.args.revisions.map(
      ({id, name, language}: {id: string; name: string; language: any}) => {
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
