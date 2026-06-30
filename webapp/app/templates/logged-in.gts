import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import FlashMessagesList from 'accent-webapp/components/flash-messages-list/index';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <FlashMessagesList @flashMessages={{@controller.flashMessages}} />

    {{outlet}}
  </template>
);
