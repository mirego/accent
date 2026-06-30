import Component from '@glimmer/component';
import config from 'accent-webapp/config/environment';
import Title from 'accent-webapp/components/project-settings/title/index';
import t from 'ember-intl/helpers/t';

interface Args {
  project: any;
}

export default class JIPT extends Component<Args> {
  <template>
    <div class='project-settings-jipt'>
      <Title @title={{t 'components.project_settings.jipt.title'}} />

      <p class='text'>
        {{t 'components.project_settings.jipt.integration_help'}}
      </p>

      <textarea
        readonly
        onClick='this.select();'
        class='code'
      >{{this.scriptContent}}</textarea>

      <hr />

      <p class='text'>
        {{t 'components.project_settings.jipt.demo_help'}}
      </p>

      <a
        href='/app/projects/{{@project.id}}/jipt-example'
        class='button button--filled'
      >

        {{t 'components.project_settings.jipt.demo_link'}}
      </a>
    </div>
  </template>
  get scriptContent() {
    const host = window.location.origin;
    const path = config.API.JIPT_SCRIPT_PATH;

    return `<script>
  window.accent=window.accent||function(){(accent.q=accent.q||[]).push(arguments);};
  accent('init',{h:'${host}',i:'${this.args.project.id}'});
</script>
<script async src="${host}${path}"></script>
`;
  }
}
