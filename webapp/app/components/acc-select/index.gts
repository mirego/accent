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
  </template>
  @action
  selectChange(event: Event) {
    this.args.onchange(event.target);
  }
}
