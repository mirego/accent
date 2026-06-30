import {action} from '@ember/object';
import Component from '@glimmer/component';
import parsedKeyProperty from 'accent-webapp/computed-macros/parsed-key';
import {LinkTo} from '@ember/routing';
import {array} from '@ember/helper';
import Item from 'accent-webapp/components/conflicts-list/item/index';

interface Args {
  selectedTranslationId: string | null;
  groupedTranslation: {
    key: string;
    translations: any[];
  };
  onFocus: (id: string) => void;
}

export default class ConflictsListGroup extends Component<Args> {
  <template>
    <li class='item {{if this.isFocused "item--focus"}}'>
      <LinkTo
        @route='logged-in.project.translation'
        @models={{array @project.id this.masterTranslation.id}}
        tabindex='-1'
        class='item-key'
      >
        {{this.translationKey.value}}

        <small class='item-key-prefix'>
          {{#if this.translationKey.prefix}}
            {{this.translationKey.prefix}}
          {{else}}
            {{@groupedTranslation.document.path}}
          {{/if}}
        </small>
      </LinkTo>

      <ul class='item-grid'>
        {{#each @groupedTranslation.translations key='id' as |translation|}}
          <li
            class='item-grid-item
              {{if translation.isTranslated "item-grid-item--translated"}}
              {{if
                translation.isConflicted
                "item-grid-item--conflicted"
                "item-grid-item--reviewed"
              }}'
          >
            <Item
              @permissions={{@permissions}}
              @project={{@project}}
              @prompts={{@prompts}}
              @translation={{translation}}
              @onCorrect={{@onCorrect}}
              @onUncorrect={{@onUncorrect}}
              @onUpdate={{@onUpdate}}
              @isFocused={{this.isFocused}}
              @onFocus={{this.handleFocus}}
            />
          </li>
        {{/each}}
      </ul>
    </li>
  </template>
  translationKey = parsedKeyProperty(this.args.groupedTranslation.key);

  get masterTranslation() {
    return this.args.groupedTranslation.translations[0];
  }

  get isFocused() {
    return this.masterTranslation.id === this.args.selectedTranslationId;
  }

  @action
  handleFocus() {
    this.args.onFocus(this.masterTranslation.id);
  }
}
