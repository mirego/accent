import Component from '@glimmer/component';
import ProjectLogo from 'accent-webapp/components/project-logo/index';
import t from 'ember-intl/helpers/t';
import TimeAgoInWordsTag from 'accent-webapp/components/time-ago-in-words-tag/index';

interface Args {
  project: any;
}

export default class ProjectsListItem extends Component<Args> {
  <template>
    <div style='{{this.colorPrimary}}' class='projects-list-item'>
      <div class='projectId- {{@project.id}} projectHeader'>
        {{#if @project.logo}}
          <span class='projectLogo'>
            <ProjectLogo @logo={{@project.logo}} />
          </span>
        {{/if}}

        <span data-test-project-name class='projectName'>
          {{@project.name}}
        </span>
      </div>

      <div class='numberStat'>
        <span class='projectUpdates'>
          {{#if @project.lastSyncedAt}}
            <span class='projectUpdate'>
              {{t 'components.projects_list.last_synced_at_label'}}
              <span class='lastSyncedAt-date'>
                <TimeAgoInWordsTag @date={{@project.lastSyncedAt}} />
              </span>
            </span>
          {{else}}
            {{t 'components.projects_list.never_synced'}}
          {{/if}}
        </span>
      </div>
    </div>
  </template>
  get colorPrimary() {
    return `--color-primary: ${this.args.project.mainColor}`;
  }
}
