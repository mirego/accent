import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import RevisionSelector from 'accent-webapp/components/revision-selector/index';
import {fn} from '@ember/helper';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <RevisionSelector
      @revisions={{@controller.revisions}}
      @revision={{@controller.revision}}
      @onSelect={{fn @controller.selectRevision}}
    />

    {{outlet}}
  </template>
);
