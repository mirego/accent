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

    <style scoped>
      .translations-activities-list {
        position: relative;
      }
      .translations-activities-list:before {
        display: block;
        position: absolute;
        content: '';
        width: 1px;
        height: 100%;
        top: 0;
        left: 9px;
        z-index: 8;
        background: var(--background-light-highlight);
      }
    </style>
  </template>
}
