import Component from '@glimmer/component';
import config from 'accent-webapp/config/environment';

interface Args {
  project: any;
}

export default class JIPT extends Component<Args> {
  get scriptContent() {
    const host = config.API.HOST;
    const url = config.API.JIPT_SCRIPT_PATH;

    return `<script>
  window.accent=window.accent||function(){(accent.q=accent.q||[]).push(arguments);};
  accent('init',{h:'${host}',i:'${this.args.project.id}'});
</script>
<script async="" src="${url}"></script>
`;
  }
}
