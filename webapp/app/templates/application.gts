import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import BasicDropdownWormhole from 'ember-basic-dropdown/components/basic-dropdown-wormhole';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <div class='app'>
      {{outlet}}
    </div>

    <BasicDropdownWormhole />
  </template>
);
