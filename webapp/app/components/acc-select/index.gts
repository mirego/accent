import Component from '@glimmer/component';
import {action} from '@ember/object';
import PowerSelect from 'ember-power-select/components/power-select';
import {on} from '@ember/modifier';
import eq from 'ember-truth-helpers/helpers/eq';

interface Args {
  customSelect?: boolean;
  searchEnabled: boolean;
  selected: any;
  options: any[];
  onchange: (value: any) => void;
  placeholder: string;
  search: (term: string) => Promise<any>;
  searchPlaceholder: string;
  matchTriggerWidth: boolean;
  renderInPlace: boolean;
}

export default class Select extends Component<Args> {
  <template>
    {{#if @searchEnabled}}
      <PowerSelect
        @options={{@options}}
        @matchTriggerWidth={{@matchTriggerWidth}}
        @searchEnabled={{@searchEnabled}}
        @selected={{@selected}}
        @search={{@search}}
        @placeholder={{@placeholder}}
        @searchPlaceholder={{@searchPlaceholder}}
        @renderInPlace={{@renderInPlace}}
        @onChange={{@onchange}}
        as |option|
      >
        {{option.label}}
      </PowerSelect>
    {{else if @customSelect}}
      <PowerSelect
        @options={{@options}}
        @selected={{@selected}}
        @placeholder={{@placeholder}}
        @renderInPlace={{@renderInPlace}}
        @onChange={{@onchange}}
        as |option|
      >
        {{option.label}}
      </PowerSelect>
    {{else if @multi}}
      <PowerSelect
        @multiple={{true}}
        @options={{@options}}
        @selected={{@selected}}
        @placeholder={{@placeholder}}
        @renderInPlace={{@renderInPlace}}
        @onChange={{@onchange}}
        as |option|
      >
        {{option.label}}
      </PowerSelect>
    {{else}}
      <div ...attributes class='root'>
        <select {{on 'change' this.selectChange}}>
          {{#each @options key='value' as |selectOption|}}
            <option
              value={{selectOption.value}}
              selected='{{if
                (eq @selected.value selectOption.value)
                "selected"
              }}'
            >
              {{selectOption.label}}
            </option>
          {{/each}}
        </select>
      </div>
    {{/if}}

    <style scoped>
      @charset "UTF-8";
      .root {
        position: relative;
      }
      .root select {
        appearance: none;
        width: 100%;
        font-size: 13px;
        cursor: pointer;
        padding: 8px 25px 8px 13px;
        background: var(--content-background);
        box-shadow: none;
        border-radius: var(--border-radius);
        border: 1px solid transparent;
        border-color: var(--background-light-highlight);
        color: var(--color-black-opacity-70);
      }
      .root:after {
        display: block;
        pointer-events: none;
        cursor: pointer;
        content: '›';
        position: absolute;
        top: 50%;
        right: 10px;
        font-size: 140%;
        transform: translateY(-50%) rotate(90deg);
      }
    </style>
  </template>
  @action
  selectChange(event: Event) {
    this.args.onchange(event.target);
  }
}
