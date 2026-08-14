import Component from '@glimmer/component';
import {LinkTo} from '@ember/routing';
import ChevronLeftSvg from 'accent-webapp/svgs/assets/chevron-left.svg';
import {scopedClass} from 'ember-scoped-css';
import t from 'ember-intl/helpers/t';

export default class BackToTranslations extends Component {
  <template>
    <LinkTo @route='logged-in.jipt.index' class='language'>
      <ChevronLeftSvg class={{scopedClass 'back-icon'}} />

      {{t 'components.jipt.back_to_translations.back'}}
    </LinkTo>

    <style scoped>
      .language {
        display: block;
        margin-bottom: 6px;
        color: var(--color-black);
        opacity: 0.8;
        font-size: 14px;
        text-decoration: none;
        transition: 0.2s ease-in-out;
        transition-property: opacity;
      }
      .language:focus,
      .language:hover {
        opacity: 1;
      }
      .language:focus .back-icon,
      .language:hover .back-icon {
        opacity: 1;
        transform: translateX(-2px);
      }

      .back-icon {
        width: 11px;
        height: 11px;
        opacity: 0.8;
        stroke: var(--color-black);
        transition: 0.2s ease-in-out;
        transition-property: opacity, transform;
      }
    </style>
  </template>
}
