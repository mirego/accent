import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import RevisionSelector from 'accent-webapp/components/revision-selector/index';
import {fn} from '@ember/helper';
import {pageTitle} from 'ember-page-title';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    {{pageTitle @controller.revisionName}}

    <RevisionSelector
      @revisions={{@controller.revisions}}
      @revision={{@controller.revision}}
      @onSelect={{fn @controller.selectRevision}}
    />

    {{outlet}}
  </template>
);
