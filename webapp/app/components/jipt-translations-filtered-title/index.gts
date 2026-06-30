import Component from '@glimmer/component';
import t from 'ember-intl/helpers/t';

interface Args {
  count: number;
}

export default class TranslationsFilteredTitle extends Component<Args> {
  <template>
    <div class='jipt-translations-filtered-title'>
      {{t
        'components.jipt.translations_filtered_title.title_count'
        count=@count
      }}
    </div>
  </template>
}
