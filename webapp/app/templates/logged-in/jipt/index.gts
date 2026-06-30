import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import TranslationsFilter from 'accent-webapp/components/translations-filter/index';
import {fn} from '@ember/helper';
import JiptTranslationsFilteredTitle from 'accent-webapp/components/jipt-translations-filtered-title/index';
import JiptTranslationsList from 'accent-webapp/components/jipt-translations-list/index';
import ResourcePagination from 'accent-webapp/components/resource-pagination/index';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    {{#unless @controller.withSelectedTranslations}}
      <TranslationsFilter
        @jipt={{true}}
        @query={{@controller.query}}
        @document={{@controller.document}}
        @documents={{@controller.model.project.documents}}
        @version={{@controller.version}}
        @versions={{@controller.model.project.versions.entries}}
        @onChangeQuery={{fn @controller.changeQuery}}
        @onChangeDocument={{fn @controller.changeDocument}}
        @onChangeVersion={{fn @controller.changeVersion}}
        @meta={{@controller.model.project.revision.translations.meta}}
      />
    {{/unless}}

    {{#if @controller.withSelectedTranslations}}
      <JiptTranslationsFilteredTitle
        @count={{@controller.filteredTranslations.length}}
      />
    {{/if}}

    <JiptTranslationsList @translations={{@controller.filteredTranslations}} />

    {{#unless @controller.withSelectedTranslations}}
      <ResourcePagination
        @meta={{@controller.model.project.revision.translations.meta}}
        @onSelectPage={{fn @controller.selectPage}}
      />
    {{/unless}}
  </template>
);
