import Component from '@ember/component';
import {computed} from '@ember/object';
import config from 'accent-webapp/config/environment';

export default Component.extend({
  scriptContent: computed('project.id', function() {
    const host = config.API.HOST;
    const url = config.API.JIPT_SCRIPT_PATH;

    return `<script>
  window.accent=window.accent||function(){(accent.q=accent.q||[]).push(arguments);};
  accent('init',{h:'${host}',i:'${this.project.id}'});
</script>
<script async="" src="${url}"></script>`;
  })
});
