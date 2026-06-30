import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import LoginForms from 'accent-webapp/components/login-forms/index';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <LoginForms
      @showLoading={{@controller.showLoading}}
      @providers={{@controller.model.authenticationProviders}}
    />
  </template>
);
