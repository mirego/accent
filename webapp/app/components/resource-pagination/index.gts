import {action} from '@ember/object';
import {or, readOnly, not} from '@ember/object/computed';
import Component from '@glimmer/component';
import {on} from '@ember/modifier';
import {fn} from '@ember/helper';
import inlineSvg from 'accent-webapp/helpers/inline-svg';

export interface PaginationMeta {
  nextPage: number;
  previousPage: number;
}

interface Args {
  meta: PaginationMeta;
  onSelectPage: (page: number) => void;
}

export default class ResourcePagination extends Component<Args> {
  <template>
    <div class='resource-pagination'>
      {{#if this.showPagination}}
        <button
          disabled={{this.disabledPrevious}}
          class='button button--white button--filled button--iconOnly'
          {{on 'click' (fn this.goToPreviousPage)}}
        >
          {{inlineSvg 'assets/chevron-left.svg' class='button-icon'}}
        </button>

        <span class='label local-label'>
          <span class='label-number'>
            {{@meta.currentPage}}
          </span>
          /
          <span class='label-number'>
            {{@meta.totalPages}}
          </span>
        </span>

        <button
          disabled={{this.disabledNext}}
          class='button button--white button--filled button--iconOnly'
          {{on 'click' (fn this.goToNextPage)}}
        >
          {{inlineSvg 'assets/chevron-right.svg' class='button-icon'}}
        </button>
      {{/if}}
    </div>
  </template>
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
