import {action} from '@ember/object';
import {or, readOnly, not} from '@ember/object/computed';
import Component from '@glimmer/component';
import {on} from '@ember/modifier';
import {fn} from '@ember/helper';
import ChevronLeftSvg from 'accent-webapp/svgs/assets/chevron-left.svg';
import ChevronRightSvg from 'accent-webapp/svgs/assets/chevron-right.svg';

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
          <ChevronLeftSvg class='button-icon' />
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
          <ChevronRightSvg class='button-icon' />
        </button>
      {{/if}}
    </div>

    <style scoped>
      .resource-pagination {
        display: flex;
        align-items: center;
        justify-content: center;
        margin-top: 30px;
      }

      .local-label {
        margin: 0 10px;
        color: var(--color-grey);
        font-size: 14px;
      }

      .label-number {
        margin: 0 4px;
      }
    </style>
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
