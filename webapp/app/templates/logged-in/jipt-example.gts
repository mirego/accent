import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import JiptExample from 'accent-webapp/components/jipt-example/index';
import {pageTitle} from 'ember-page-title';
import t from 'ember-intl/helpers/t';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    {{pageTitle @controller.model.project.name}}
    {{pageTitle (t 'general.page_titles.jipt_example')}}

    <JiptExample
      @loading={{@controller.model.loading}}
      @project={{@controller.model.project}}
    />
  </template>
);
