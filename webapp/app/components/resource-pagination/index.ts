import {action} from '@ember/object';
import {or, readOnly, not} from '@ember/object/computed';
import Component from '@glimmer/component';

export interface PaginationMeta {
  nextPage: number;
  previousPage: number;
}

interface Args {
  meta: PaginationMeta;
  onSelectPage: (page: number) => void;
}

export default class ResourcePagination extends Component<Args> {
  @or('args.meta.{nextPage,previousPage}')
  showPagination: boolean;

  @readOnly('args.meta.previousPage')
  hasPrevious: boolean;

  @readOnly('args.meta.nextPage')
  hasNext: boolean;

  @not('hasPrevious')
  disabledPrevious: boolean;

  @not('hasNext')
  disabledNext: boolean;

  @action
  goToNextPage() {
    if (!this.args.meta.nextPage) return;

    this.args.onSelectPage(this.args.meta.nextPage);
  }

  @action
  goToPreviousPage() {
    if (!this.args.meta.previousPage) return;

    this.args.onSelectPage(this.args.meta.previousPage);
  }
}
