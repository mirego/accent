import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import {action} from '@ember/object';

interface Args {
  revisionOperations: any;
}

export default class RevisionOperations extends Component<Args> {
  @tracked
  selectedRevisionOperation = this.args.revisionOperations[0];

  get mappedRevisions() {
    return this.args.revisionOperations.map((revisionOperation: any) => {
      return {
        label: revisionOperation.language.name,
        value: revisionOperation.language.id
      };
    });
  }

  get mappedSelectedRevision() {
    return this.mappedRevisions.find(
      (revision: any) =>
        revision.value === this.selectedRevisionOperation.language.id
    );
  }

  @tracked
  shouldShowStats = true;

  @tracked
  shouldShowOperations = false;

  @tracked
  shouldHideDetails = false;

  @action
  onSelectRevision(revision: {label: string; value: string}) {
    this.selectedRevisionOperation = this.args.revisionOperations.find(
      ({language: {id}}: any) => id === revision.value
    );
  }

  @action
  showStats() {
    this.shouldShowStats = true;
    this.shouldShowOperations = false;
    this.shouldHideDetails = false;
  }

  @action
  showOperations() {
    this.shouldShowStats = false;
    this.shouldShowOperations = true;
    this.shouldHideDetails = false;
  }

  @action
  hideDetails() {
    this.shouldShowStats = false;
    this.shouldShowOperations = false;
    this.shouldHideDetails = true;
  }
}
