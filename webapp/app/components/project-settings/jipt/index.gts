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

    <style scoped>
      .project-settings-jipt {
        margin-top: 30px;
      }
      .project-settings-jipt hr {
        margin: 20px 0;
        border: 0;
        height: 1px;
        background: var(--background-light-highlight);
      }

      .text {
        max-width: 490px;
        margin: 10px 0;
        font-size: 13px;
        font-style: italic;
      }

      .title {
        margin-top: 20px;
        border-bottom: 1px solid var(--background-light-highlight);
        padding-bottom: 10px;
        font-size: 16px;
        font-weight: 300;
        color: var(--text-color-normal);
      }

      .link {
        font-size: 12px;
      }

      .code {
        display: inline-block;
        width: 100%;
        margin: 10px 0 0;
        padding: 8px 10px;
        height: 120px;
        word-break: keep-all;
        background: var(--background-light);
        font-family: var(--font-monospace);
        font-size: 15px;
        border: 2px solid var(--background-light-highlight);
        border-radius: var(--border-radius);
        color: var(--text-color-normal);
        transition-property: border-color, box-shadow;
        transition: 0.3s ease-in-out;
        resize: none;
      }
      .code:focus {
        outline: none;
        border-color: color-mix(in srgb, var(--color-primary) 70%, transparent);
        box-shadow: 0 0 3px 2px
          color-mix(in srgb, var(--color-primary) 10%, transparent);
      }
      .code:focus::-moz-selection {
        background: color-mix(in srgb, var(--color-primary) 10%, transparent);
      }
      .code:focus::selection {
        background: color-mix(in srgb, var(--color-primary) 10%, transparent);
      }
    </style>
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
