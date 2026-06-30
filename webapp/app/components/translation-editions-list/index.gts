import Component from '@glimmer/component';
import Item from 'accent-webapp/components/translation-editions-list/item/index';
import EmptyContent from 'accent-webapp/components/empty-content/index';
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
        <EmptyContent class='empty-content'>
          {{t 'components.translation_editions_list.no_translations'}}
          <div>
            {{t 'components.translation_editions_list.no_versions'}}
            <LinkTo @route='logged-in.project.versions' class='link'>
              {{t 'components.translation_editions_list.no_versions_link'}}
            </LinkTo>
          </div>
        </EmptyContent>
      {{/each}}
    </ul>
  </template>
}
