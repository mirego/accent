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
  </template>
  get colors() {
    return `
      .projectId-${this.args.project.id} {
        --color-primary: ${this.args.project.mainColor};
      }
    `;
  }
}
