import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import JiptHeader from 'accent-webapp/components/jipt-header/index';
import RevisionSelector from 'accent-webapp/components/revision-selector/index';
import {fn} from '@ember/helper';
import {htmlSafe} from '@ember/template';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <style>
      body {
      {{htmlSafe @controller.colors}}
      --body-background: #fff; }
    </style>

    <div>
      <JiptHeader @project={{@controller.model.project}} />

      <RevisionSelector
        @jipt={{true}}
        @revisions={{@controller.revisions}}
        @revision={{@controller.revision.id}}
        @withRevisionsCount={{false}}
        @onSelect={{fn @controller.selectRevision}}
      />

      {{outlet}}
    </div>
  </template>
);
