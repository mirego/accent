import Component from '@glimmer/component';
import ActivityItem from 'accent-webapp/components/activity-item/index';
import EmptyHero from 'accent-webapp/components/empty-hero/index';
import t from 'ember-intl/helpers/t';

interface Args {
  permissions: Record<string, true>;
  activities: any;
  project: any;
  compact: boolean;
  withFilters?: boolean;
}

export default class ProjectActivitiesList extends Component<Args> {
  <template>
    {{#if this.hasActivities}}
      <ul class='list'>
        {{#each @activities key='id' as |activity|}}
          <ActivityItem
            @compact={{@compact}}
            @permissions={{@permissions}}
            @showTranslationLink={{true}}
            @componentTranslationPrefix='project_activities_list_item'
            @activity={{activity}}
            @project={{@project}}
          />
        {{/each}}
      </ul>
    {{else if @withFilters}}
      <EmptyHero
        @title={{t 'components.project_activities_list.empty_filters_title'}}
        @text={{t 'components.project_activities_list.empty_filters_text'}}
      />
    {{else}}
      <EmptyHero
        @title={{t 'components.project_activities_list.empty_title'}}
        @text={{t 'components.project_activities_list.empty_activities_text'}}
      />
    {{/if}}

    <style scoped>
      .list {
        position: relative;
      }
      .list:before {
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
  get hasActivities() {
    return Boolean(this.args.activities?.length);
  }
}
