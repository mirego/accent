import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import PageTitle from 'accent-webapp/components/page-title/index';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import t from 'ember-intl/helpers/t';
import End from 'accent-webapp/components/page-title/end/index';
import {get, fn} from '@ember/helper';
import {LinkTo} from '@ember/routing';
import {on} from '@ember/modifier';
import ProgressLine from 'accent-webapp/components/skeleton-ui/progress-line/index';
import DocumentsListSkeleton from 'accent-webapp/components/skeleton-ui/documents-list/index';
import DocumentsList from 'accent-webapp/components/documents-list/index';
import DocumentsAddButton from 'accent-webapp/components/documents-add-button/index';
import DocumentsMachineTranslationsButton from 'accent-webapp/components/documents-machine-translations-button/index';
import ResourcePagination from 'accent-webapp/components/resource-pagination/index';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <PageTitle>
      {{inlineSvg '/assets/file.svg'}}
      <h1>{{t 'components.page_title.files'}}</h1>

      <End>
        {{#if (get @controller.permissions 'exportRevision')}}
          <LinkTo
            @route='logged-in.project.files.export-all'
            @model={{@controller.model.project.id}}
            class='button button--white button--filled'
          >
            {{inlineSvg '/assets/export.svg' class='button-icon'}}
            {{t 'components.documents_list.export_all'}}
          </LinkTo>
        {{/if}}

        <button
          class='button
            {{if
              @controller.excludeEmptyTranslations
              "button--grey"
              "button--white"
            }}
            button--filled'
          {{on 'click' @controller.toggleExcludeEmptyTranslations}}
        >
          {{#if @controller.excludeEmptyTranslations}}
            {{inlineSvg '/assets/eye.svg' class='button-icon'}}
            {{t 'components.documents_list.show_deleted'}}
          {{else}}
            {{inlineSvg '/assets/eye.svg' class='button-icon'}}
            {{t 'components.documents_list.hide_deleted'}}
          {{/if}}
        </button>
      </End>
    </PageTitle>

    {{#if @controller.model.loading}}
      <ProgressLine />
    {{/if}}

    {{#if @controller.showSkeleton}}
      <DocumentsListSkeleton />
    {{else}}
      <DocumentsList
        @permissions={{@controller.permissions}}
        @documents={{@controller.model.documents.entries}}
        @project={{@controller.model.project}}
        @onDelete={{fn @controller.deleteDocument}}
        @onUpdate={{fn @controller.updateDocument}}
      />

      {{#if (get @controller.permissions 'sync')}}
        <DocumentsAddButton @project={{@controller.model.project}} />
      {{/if}}

      {{#if (get @controller.permissions 'machineTranslationsTranslate')}}
        <DocumentsMachineTranslationsButton
          @project={{@controller.model.project}}
        />
      {{/if}}

      <ResourcePagination
        @meta={{@controller.model.documents.meta}}
        @onSelectPage={{fn @controller.selectPage}}
      />

      {{outlet}}
    {{/if}}
  </template>
);
