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

    <style scoped>
      .projects-list-item {
        padding: 10px 15px 12px;
        transition: 0.2s ease-in-out;
        transition-property: box-shadow, border-color, background;
        border-radius: var(--border-radius);
        border: 1px solid var(--content-background-border);
        background: var(--content-background);
        color: var(--text-color-normal);
        --text-color-normal: color-mix(
          in oklab,
          var(--color-primary),
          var(--input-color) 20%
        );
      }
      .projects-list-item:focus,
      .projects-list-item:hover {
        border-color: color-mix(in srgb, var(--color-primary) 50%, transparent);
        background: linear-gradient(
          to bottom,
          color-mix(in srgb, var(--color-primary) 4%, transparent) 0%,
          transparent 65%
        );
      }
      .projects-list-item:focus .projectName,
      .projects-list-item:hover .projectName {
        color: color-mix(in srgb, var(--color-primary) 94%, #fff);
      }

      .projectHeader {
        display: flex;
        align-items: center;
        margin-bottom: 4px;
      }

      .projectName {
        transition: 0.2s ease-in-out;
        transition-property: color;
        font-weight: 500;
        font-size: 18px;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }

      .projectLogo {
        display: flex;
        align-items: center;
        margin-right: 8px;
        font-size: 21px;
        line-height: 1;
      }
      .projectLogo :global(svg) {
        width: 25px;
        height: 20px;
      }

      .projectUpdates {
        display: block;
        opacity: 0.6;
        color: var(--text-color-normal);
        font-style: italic;
        font-size: 11px;
      }

      .projectUpdate {
        margin-right: 6px;
      }

      .numberStat {
        display: flex;
        justify-content: space-between;
        align-items: center;
      }
    </style>
  </template>
  get colorPrimary() {
    return `--color-primary: ${this.args.project.mainColor}`;
  }
}
