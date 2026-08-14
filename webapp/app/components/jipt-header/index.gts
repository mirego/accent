import Component from '@glimmer/component';
import LogoSvg from 'accent-webapp/svgs/assets/logo.svg';
import {concat} from '@ember/helper';
import {scopedClass} from 'ember-scoped-css';
import t from 'ember-intl/helpers/t';

interface Args {
  project: any;
}

export default class JIPTHeader extends Component<Args> {
  <template>
    <div class='jipt-header'>
      <div class='applicationLogo'>
        <LogoSvg
          class={{concat
            (scopedClass 'applicationLogo-image')
            ' '
            (scopedClass 'applicationLogo-image--linked')
          }}
        />
      </div>

      <div class='project'>
        {{t 'general.application_name'}}
      </div>
    </div>

    <style scoped>
      .jipt-header {
        position: sticky;
        top: 0;
        z-index: 5000;
        display: flex;
        padding: 14px 10px;
        box-shadow: 0 3px 10px var(--shadow-color);
        background: var(--content-background);
      }

      .project {
        margin: 0 0 0 10px;
        font-size: 14px;
        font-weight: 700;
        color: var(--color-black);
      }

      .applicationLogo {
        display: inline-flex;
        align-items: center;
        text-decoration: none;
      }
      .applicationLogo circle {
        fill: var(--content-background);
      }
      .applicationLogo path {
        fill: var(--color-primary);
      }

      .applicationLogo-image {
        width: 18px;
        height: 18px;
      }
    </style>
  </template>
}
