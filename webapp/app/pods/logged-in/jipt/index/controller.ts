import {equal, and, readOnly} from '@ember/object/computed';
import {action} from '@ember/object';
import Controller from '@ember/controller';
import {tracked} from '@glimmer/tracking';

export default class IndexController extends Controller {
  queryParams = ['query', 'page', 'document', 'version'];

  @tracked
  query = '';

  @tracked
  page = 1;

  @tracked
  document: string | null = null;

  @tracked
  version: string | null = null;

  @readOnly('model.project.revision.translations.entries')
  translations: any;

  @equal('translations', undefined)
  emptyEntries: boolean;

  @equal('query', '')
  emptyQuery: boolean;

  @and('emptyEntries', 'model.loading', 'emptyQuery')
  showSkeleton: boolean;

  @and('emptyEntries', 'model.loading')
  showLoading: boolean;

  @readOnly('model.selectedTranslationIds')
  withSelectedTranslations: any;

  get filteredTranslations() {
    if (!this.withSelectedTranslations) return this.translations;

    const ids = this.withSelectedTranslations.split(',');

    return this.translations.filter((translation: any) => {
      return ids.includes(translation.id);
    });
  }

  @action
  changeQuery(query: string) {
    this.page = 1;
    this.query = query;
  }

  @action
  changeVersion(versionId: string) {
    this.page = 1;
    this.version = versionId;
  }

  @action
  changeDocument(documentId: string) {
    this.page = 1;
    this.document = documentId;
  }

  @action
  selectPage(page: number) {
    window.scrollTo(0, 0);

    this.page = page;
  }
}
