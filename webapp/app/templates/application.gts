import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import BasicDropdownWormhole from 'ember-basic-dropdown/components/basic-dropdown-wormhole';
import {pageTitle} from 'ember-page-title';
import t from 'ember-intl/helpers/t';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    {{pageTitle (t 'general.application_name')}}

    <div class='app'>
      {{outlet}}
    </div>

    <BasicDropdownWormhole />
  </template>
);
