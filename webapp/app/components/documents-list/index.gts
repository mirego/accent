import Component from '@glimmer/component';
import Item from 'accent-webapp/components/documents-list/item/index';
import EmptyContent from 'accent-webapp/components/empty-content/index';
import t from 'ember-intl/helpers/t';

interface Args {
  permissions: Record<string, true>;
  documents: any;
  project: any;
  onDelete: (documentEntity: any) => Promise<void>;
  onUpdate: (documentEntity: any, path: string) => Promise<void>;
}

interface Document {
  translationsCount: number;
}

export default class DocumentsList extends Component<Args> {
  <template>
    <ul class='documents-list'>
      {{#each this.documents key='id' as |document|}}
        <Item
          @permissions={{@permissions}}
          @document={{document}}
          @onDelete={{@onDelete}}
          @onUpdate={{@onUpdate}}
          @project={{@project}}
        />
      {{else}}
        <div class='empty-content'>
          <EmptyContent @text={{t 'components.documents_list.empty_text'}} />
        </div>
      {{/each}}
    </ul>
  </template>
  get documents() {
    const emptyDocuments = this.args.documents.filter(
      (document: Document) => document.translationsCount === 0
    );
    const documents = this.args.documents.filter(
      (document: Document) => document.translationsCount !== 0
    );

    return [...documents, ...emptyDocuments];
  }
}
