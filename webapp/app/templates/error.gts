import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import ErrorSection from 'accent-webapp/components/error-section/index';
import {fn} from '@ember/helper';
import ApplicationFooter from 'accent-webapp/components/application-footer/index';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <ErrorSection
      @status={{@controller.status}}
      @title={{@controller.title}}
      @text={{@controller.text}}
      @onLogout={{fn @controller.logout}}
      @isAuthenticated={{@controller.session.isAuthenticated}}
    />

    <ApplicationFooter />
  </template>
);
