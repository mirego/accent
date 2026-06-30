import Component from '@glimmer/component';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
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
        {{inlineSvg
          'assets/logo.svg'
          class=(concat
            (scopedClass 'applicationLogo-image')
            ' '
            (scopedClass 'applicationLogo-image--linked')
          )
        }}
      </div>

      <div class='project'>
        {{t 'general.application_name'}}
      </div>
    </div>
  </template>
}
