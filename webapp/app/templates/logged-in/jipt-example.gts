import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import JiptExample from 'accent-webapp/components/jipt-example/index';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <JiptExample
      @loading={{@controller.model.loading}}
      @project={{@controller.model.project}}
    />
  </template>
);
