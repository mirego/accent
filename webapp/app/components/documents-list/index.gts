import Component from '@glimmer/component';
import Item from 'accent-webapp/components/documents-list/item/index';
import EmptyHero from 'accent-webapp/components/empty-hero/index';
import t from 'ember-intl/helpers/t';

interface Args {
  permissions: Record<string, true>;
  documents: any;
  project: any;
  withFilters?: boolean;
  onDelete: (documentEntity: any) => Promise<void>;
  onUpdate: (documentEntity: any, path: string) => Promise<void>;
}

interface Document {
  translationsCount: number;
}

export default class DocumentsList extends Component<Args> {
  <template>
    {{#if this.hasDocuments}}
      <ul class='documents-list'>
        {{#each this.documents key='id' as |document|}}
          <Item
            @permissions={{@permissions}}
            @document={{document}}
            @onDelete={{@onDelete}}
            @onUpdate={{@onUpdate}}
            @project={{@project}}
          />
        {{/each}}
      </ul>
    {{else if @withFilters}}
      <EmptyHero
        @title={{t 'components.documents_list.empty_filters_title'}}
        @text={{t 'components.documents_list.empty_filters_text'}}
      />
    {{else}}
      <EmptyHero
        @title={{t 'components.documents_list.empty_title'}}
        @text={{t 'components.documents_list.empty_text'}}
      />
    {{/if}}

    <style scoped>
      .documents-list {
        width: 100%;
        display: flex;
        flex-wrap: wrap;
        margin-top: 3px;
        margin-bottom: 20px;
      }
    </style>
  </template>
  get hasDocuments() {
    return Boolean(this.args.documents?.length);
  }

  get documents() {
    const emptyDocuments = this.args.documents.filter(
      (document: Document) => document.translationsCount === 0,
    );
    const documents = this.args.documents.filter(
      (document: Document) => document.translationsCount !== 0,
    );

    return [...documents, ...emptyDocuments];
  }
}
