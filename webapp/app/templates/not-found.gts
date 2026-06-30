import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import ErrorSection from 'accent-webapp/components/error-section/index';
import t from 'ember-intl/helpers/t';
import {fn} from '@ember/helper';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <ErrorSection
      @status={{t 'pods.error.not_found.status'}}
      @title={{t 'pods.error.not_found.title'}}
      @text={{t 'pods.error.not_found.text'}}
      @onLogout={{fn @controller.logout}}
      @isAuthenticated={{@controller.session.isAuthenticated}}
    />
  </template>
);
