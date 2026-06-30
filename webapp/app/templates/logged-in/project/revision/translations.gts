import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import TranslationsFilter from 'accent-webapp/components/translations-filter/index';
import {fn} from '@ember/helper';
import ProgressLine from 'accent-webapp/components/skeleton-ui/progress-line/index';
import TranslationsListSkeleton from 'accent-webapp/components/skeleton-ui/translations-list/index';
import TranslationsList from 'accent-webapp/components/translations-list/index';
import LoadingContent from 'accent-webapp/components/loading-content/index';
import t from 'ember-intl/helpers/t';
import ResourcePagination from 'accent-webapp/components/resource-pagination/index';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <TranslationsFilter
      @query={{@controller.query}}
      @document={{@controller.document}}
      @documents={{@controller.model.documents}}
      @version={{@controller.version}}
      @versions={{@controller.model.project.versions.entries}}
      @revisions={{@controller.revisions}}
      @withAdvancedFilters={{@controller.withAdvancedFilters}}
      @isTextEmptyFilter={{@controller.isTextEmpty}}
      @isTextNotEmptyFilter={{@controller.isTextNotEmpty}}
      @isAddedLastSyncFilter={{@controller.isAddedLastSync}}
      @isCommentedOnFilter={{@controller.isCommentedOn}}
      @isConflictedFilter={{@controller.isConflicted}}
      @isTranslatedFilter={{@controller.isTranslated}}
      @onChangeQuery={{fn @controller.changeQuery}}
      @onChangeAdvancedFilterBoolean={{fn
        @controller.changeAdvancedFilterBoolean
      }}
      @onChangeDocument={{fn @controller.changeDocument}}
      @onChangeVersion={{fn @controller.changeVersion}}
      @meta={{@controller.model.translations.meta}}
    />

    {{#if @controller.model.loading}}
      <ProgressLine />
    {{/if}}

    {{#if @controller.showSkeleton}}
      <TranslationsListSkeleton />
    {{else if @controller.showLoading}}
      <LoadingContent
        @label={{t 'pods.project.translations.loading_content'}}
      />
    {{else}}
      <TranslationsList
        @version={{@controller.version}}
        @versions={{@controller.model.project.versions.entries}}
        @project={{@controller.model.project}}
        @prompts={{@controller.model.prompts}}
        @permissions={{@controller.permissions}}
        @translations={{@controller.model.translations.entries}}
        @withAdvancedFilters={{@controller.withAdvancedFilters}}
        @query={{@controller.query}}
        @onUpdateText={{fn @controller.updateText}}
      />
      <ResourcePagination
        @meta={{@controller.model.translations.meta}}
        @onSelectPage={{fn @controller.selectPage}}
      />
    {{/if}}
  </template>
);
