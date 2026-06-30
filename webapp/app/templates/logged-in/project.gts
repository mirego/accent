import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import AccWrapper from 'accent-webapp/components/acc-wrapper/index';
import Sidebar from 'accent-webapp/components/acc-wrapper/sidebar/index';
import ProjectNavigationSkeleton from 'accent-webapp/components/skeleton-ui/project-navigation/index';
import ProjectNavigation from 'accent-webapp/components/project-navigation/index';
import Content from 'accent-webapp/components/acc-wrapper/content/index';
import ErrorSection from 'accent-webapp/components/error-section/index';
import t from 'ember-intl/helpers/t';
import RecentProjectCache from 'accent-webapp/components/recent-project-cache/index';
import {htmlSafe} from '@ember/template';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <div>
      {{#unless @controller.showError}}
        <style>
          html body {
          {{htmlSafe @controller.colors}}
          } html[data-theme='dark'] body {
          {{htmlSafe @controller.darkColors}}
          }
        </style>
      {{/unless}}

      <AccWrapper>
        {{#unless @controller.showError}}
          <Sidebar>
            {{#if @controller.model.loading}}
              <ProjectNavigationSkeleton />
            {{else if @controller.showError}}
              <ProjectNavigationSkeleton />
            {{else}}
              <ProjectNavigation
                @project={{@controller.project}}
                @permissions={{@controller.permissions}}
                @revisions={{@controller.revisions}}
              />
            {{/if}}
          </Sidebar>
        {{/unless}}

        <Content>
          {{#if @controller.showError}}
            <ErrorSection
              @status={{t 'pods.error.unauthorized.status'}}
              @title={{t 'pods.error.unauthorized.title'}}
              @text={{t 'pods.error.unauthorized.text'}}
              @isAuthenticated={{@controller.session.isAuthenticated}}
            />
          {{else}}
            {{#unless @controller.model.loading}}
              <RecentProjectCache @project={{@controller.project}} />
            {{/unless}}

            {{outlet}}
          {{/if}}
        </Content>
      </AccWrapper>
    </div>
  </template>
);
