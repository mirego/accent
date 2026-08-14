import Component from '@glimmer/component';
import Item from 'accent-webapp/components/translation-editions-list/item/index';
import EmptyState from 'accent-webapp/components/empty-state/index';
import HistorySvg from 'accent-webapp/svgs/assets/history.svg';
import t from 'ember-intl/helpers/t';
import {LinkTo} from '@ember/routing';

interface Args {
  project: any;
  revisionId: string;
  translations: any;
  onUpdateText: (translation: any, editText: string) => Promise<void>;
}

export default class TranslationEditionsList extends Component<Args> {
  <template>
    <ul class='translations-list'>
      {{#each @translations key='id' as |translation|}}
        <Item
          @translation={{translation}}
          @revisions={{@revisions}}
          @prompts={{@prompts}}
          @permissions={{@permissions}}
          @project={{@project}}
          @onUpdateText={{@onUpdateText}}
        />
      {{else}}
        <EmptyState
          @icon={{HistorySvg}}
          @title={{t 'components.translation_editions_list.no_translations'}}
          @text={{t 'components.translation_editions_list.no_versions'}}
        >
          <LinkTo @route='logged-in.project.versions' class='link'>
            {{t 'components.translation_editions_list.no_versions_link'}}
          </LinkTo>
        </EmptyState>
      {{/each}}
    </ul>

    <style scoped>
      .translations-list {
        margin-top: 20px;
      }

      .empty-content {
        margin-top: 20px;
      }
    </style>
  </template>
}
