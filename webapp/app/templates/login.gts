import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import LoginForms from 'accent-webapp/components/login-forms/index';
import {pageTitle} from 'ember-page-title';
import t from 'ember-intl/helpers/t';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    {{pageTitle (t 'general.page_titles.login')}}

    <LoginForms
      @showLoading={{@controller.showLoading}}
      @providers={{@controller.model.authenticationProviders}}
    />
  </template>
);
