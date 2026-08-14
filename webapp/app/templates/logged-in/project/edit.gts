import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import PageTitle from 'accent-webapp/components/page-title/index';
import GearSvg from 'accent-webapp/svgs/assets/gear.svg';
import t from 'ember-intl/helpers/t';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <PageTitle>
      <GearSvg />
      <h1>{{t 'components.page_title.project_edit'}}</h1>
    </PageTitle>

    {{outlet}}
  </template>
);
