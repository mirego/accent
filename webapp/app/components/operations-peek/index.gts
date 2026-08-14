import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import {action} from '@ember/object';
import AccSelect from 'accent-webapp/components/acc-select/index';
import {fn} from '@ember/helper';
import {on} from '@ember/modifier';
import t from 'ember-intl/helpers/t';
import Item from 'accent-webapp/components/operations-peek/item/index';

interface Args {
  revisionOperations: any;
}

export default class RevisionOperations extends Component<Args> {
  <template>
    <div class='languageHeader'>
      <AccSelect
        @searchEnabled={{false}}
        @selected={{this.mappedSelectedRevision}}
        @options={{this.mappedRevisions}}
        @onchange={{fn this.onSelectRevision}}
        class='languageHeader-select'
      />

      <div class='languageHeader-displayOptions'>
        <button
          disabled={{this.shouldShowStats}}
          class='languageHeader-displayOptions-button'
          {{on 'click' (fn this.showStats)}}
        >
          {{t 'components.operations_peek.item.overview'}}
        </button>

        <button
          disabled={{this.shouldShowOperations}}
          class='languageHeader-displayOptions-button'
          {{on 'click' (fn this.showOperations)}}
        >
          {{t 'components.operations_peek.item.details'}}
        </button>

        <button
          disabled={{this.shouldHideDetails}}
          class='languageHeader-displayOptions-button'
          {{on 'click' (fn this.hideDetails)}}
        >
          {{t 'components.operations_peek.item.hide'}}
        </button>
      </div>
    </div>

    <Item
      @shouldHideDetails={{this.shouldHideDetails}}
      @shouldShowOperations={{this.shouldShowOperations}}
      @shouldShowStats={{this.shouldShowStats}}
      @revisionOperation={{this.selectedRevisionOperation}}
    />

    <style scoped>
      .languageHeader {
        display: flex;
        justify-content: space-between;
      }

      .languageHeader-select select {
        font-weight: bold;
        border: 0;
        padding-left: 0;
        background: var(--content-background);
        font-size: 15px;
      }

      .languageHeader-displayOptions-button {
        padding: 0 10px;
        background: none;
        border-right: 1px solid var(--background-light-highlight);
        color: var(--color-black);
        font-size: 13px;
      }
      .languageHeader-displayOptions-button:focus {
        outline: none;
        opacity: 0.6;
      }
      .languageHeader-displayOptions-button:last-of-type {
        border-right-color: transparent;
      }

      .languageHeader-displayOptions-button[disabled] {
        color: var(--color-primary);
      }
    </style>
  </template>
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
