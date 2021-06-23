import Component from '@glimmer/component';
import {action} from '@ember/object';
import {tracked} from '@glimmer/tracking';

interface Args {
  revisionOperation: any;
  shouldShowStats: boolean;
  shouldShowOperations: boolean;
  shouldHideDetails: boolean;
}

export default class OperationsPeekItem extends Component<Args> {
  @tracked
  searchQuery = '';

  get operations() {
    if (!this.searchQuery) return this.args.revisionOperation.operations;

    const query = new RegExp(this.searchQuery, 'i');

    return this.args.revisionOperation.operations.filter(
      (operation: {key: string; previousText: string; text: string}) => {
        return [
          operation.key,
          operation.previousText,
          operation.text,
        ].some((text) => text.match(query));
      }
    );
  }

  @action
  filterOperations(event: Event) {
    const target = event.target as HTMLInputElement;
    this.searchQuery = target.value;
  }
}
