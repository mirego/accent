import Component from '@glimmer/component';
import ActivityItem from 'accent-webapp/components/activity-item/index';

interface Args {
  permissions: Record<string, true>;
  project: any;
  activities: any;
}

export default class TranslationActivitiesList extends Component<Args> {
  <template>
    <ul class='translations-activities-list'>
      {{#each @activities key='id' as |activity|}}
        <ActivityItem
          @project={{@project}}
          @permissions={{@permissions}}
          @showTranslationLink={{false}}
          @componentTranslationPrefix='translation_activities_list_item'
          @activity={{activity}}
        />
      {{/each}}
    </ul>
  </template>
}
