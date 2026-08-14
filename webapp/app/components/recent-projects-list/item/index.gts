import Component from '@glimmer/component';
import ProjectLogo from 'accent-webapp/components/project-logo/index';
import {htmlSafe} from '@ember/template';

interface Args {
  project: any;
}

export default class RecentProjectsListItem extends Component<Args> {
  <template>
    <div class='projectId-{{@project.id}} project'>
      {{#if @project.logo}}
        <span class='projectLogo'>
          <ProjectLogo @logo={{@project.logo}} />
        </span>
      {{/if}}

      <span data-test-project-name class='projectName'>
        {{@project.name}}
      </span>
      <style>
        {{htmlSafe this.colors}}
      </style>
    </div>

    <style scoped>
      .project {
        display: flex;
      }

      .projectName {
        transition: 0.2s ease-in-out;
        transition-property: color;
        font-weight: 600;
        font-size: 13px;
        color: var(--color-primary);
      }

      .projectLogo {
        display: flex;
        align-items: center;
        margin-right: 8px;
        font-size: 15px;
        line-height: 1;
      }
      .projectLogo :global(svg) {
        width: 25px;
        height: 20px;
      }
    </style>
  </template>
  get colors() {
    return `
      .projectId-${this.args.project.id} {
        --color-primary: ${this.args.project.mainColor};
      }
    `;
  }
}
