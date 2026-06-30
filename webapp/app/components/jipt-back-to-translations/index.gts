import Component from '@glimmer/component';
import {LinkTo} from '@ember/routing';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import {scopedClass} from 'ember-scoped-css';
import t from 'ember-intl/helpers/t';

export default class BackToTranslations extends Component {
  <template>
    <LinkTo @route='logged-in.jipt.index' class='language'>
      {{inlineSvg 'assets/chevron-left.svg' class=(scopedClass 'back-icon')}}

      {{t 'components.jipt.back_to_translations.back'}}
    </LinkTo>
  </template>
}
