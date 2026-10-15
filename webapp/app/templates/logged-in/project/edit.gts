import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import PageTitle from 'accent-webapp/components/page-title/index';
import GearSvg from 'accent-webapp/svgs/assets/gear.svg';
import t from 'ember-intl/helpers/t';
import {pageTitle} from 'ember-page-title';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    {{pageTitle (t 'general.page_titles.settings')}}

    <PageTitle>
      <GearSvg />
      <h1>{{t 'components.page_title.project_edit'}}</h1>
    </PageTitle>

    {{outlet}}
  </template>
);
