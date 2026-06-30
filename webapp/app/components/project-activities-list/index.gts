import Component from '@glimmer/component';
import ActivityItem from 'accent-webapp/components/activity-item/index';
import EmptyContent from 'accent-webapp/components/empty-content/index';
import t from 'ember-intl/helpers/t';

interface Args {
  permissions: Record<string, true>;
  activities: any;
  project: any;
  compact: boolean;
}

export default class ProjectActivitiesList extends Component<Args> {
  <template>
    {{#if @activities}}
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
    {{else}}
      <div class='empty-content'>
        <EmptyContent
          @center={{true}}
          @iconPath='assets/empty.svg'
          @text={{t 'components.project_activities_list.empty_activities_text'}}
        />
      </div>
    {{/if}}
  </template>
}
