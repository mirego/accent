import RouteTemplate from 'ember-route-template';
import type {RouteTemplateSignature} from 'accent-webapp/utils/route-template-signature';
import ConflictsFilters from 'accent-webapp/components/conflicts-filters/index';
import {fn} from '@ember/helper';
import ProgressLine from 'accent-webapp/components/skeleton-ui/progress-line/index';
import TranslationsList from 'accent-webapp/components/skeleton-ui/translations-list/index';
import LoadingContent from 'accent-webapp/components/loading-content/index';
import t from 'ember-intl/helpers/t';
import ConflictsList from 'accent-webapp/components/conflicts-list/index';
import ResourcePagination from 'accent-webapp/components/resource-pagination/index';
export default RouteTemplate<RouteTemplateSignature>(
  <template>
    <ConflictsFilters
      @meta={{@controller.model.groupedTranslations.meta}}
      @conflicts={{@controller.model.groupedTranslations.entries}}
      @document={{@controller.document}}
      @documents={{@controller.model.documents}}
      @version={{@controller.version}}
      @versions={{@controller.model.versions}}
      @relatedRevisions={{@controller.relatedRevisions}}
      @defaultRelatedRevisions={{@controller.model.relatedRevisions}}
      @revisions={{@controller.model.revisions}}
      @withAdvancedFilters={{@controller.withAdvancedFilters}}
      @isTextEmptyFilter={{@controller.isTextEmpty}}
      @isTextNotEmptyFilter={{@controller.isTextNotEmpty}}
      @isAddedLastSyncFilter={{@controller.isAddedLastSync}}
      @isCommentedOnFilter={{@controller.isCommentedOn}}
      @isConflictedFilter={{@controller.isConflicted}}
      @isTranslatedFilter={{@controller.isTranslated}}
      @query={{@controller.query}}
      @onChangeDocument={{@controller.changeDocument}}
      @onChangeQuery={{@controller.changeQuery}}
      @onChangeVersion={{@controller.changeVersion}}
      @onChangeRevisions={{@controller.changeRelatedRevisions}}
      @onChangeAdvancedFilterBoolean={{fn
        @controller.changeAdvancedFilterBoolean
      }}
    />

    {{#if @controller.model.loading}}
      <ProgressLine />
    {{/if}}

    {{#if @controller.showSkeleton}}
      <TranslationsList />
    {{else if @controller.showLoading}}
      <LoadingContent
        @label={{t 'pods.project.translations.loading_content'}}
      />
    {{else}}
      <ConflictsList
        @permissions={{@controller.permissions}}
        @version={{@controller.version}}
        @versions={{@controller.model.versions}}
        @project={{@controller.model.project}}
        @revisions={{@controller.revisions}}
        @prompts={{@controller.model.prompts}}
        @groupedRevisions={{@controller.model.groupedTranslations.revisions}}
        @groupedTranslations={{@controller.model.groupedTranslations.entries}}
        @onCorrect={{@controller.correctConflict}}
        @onUncorrect={{@controller.uncorrectConflict}}
        @onUpdate={{@controller.updateConflict}}
      />
      <ResourcePagination
        @meta={{@controller.model.groupedTranslations.meta}}
        @onSelectPage={{fn @controller.selectPage}}
      />
    {{/if}}
  </template>
);
