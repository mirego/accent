import {service} from '@ember/service';
import {readOnly, equal, and} from '@ember/object/computed';
import {action} from '@ember/object';
import Controller from '@ember/controller';
import correctAllRevisionQuery from 'accent-webapp/queries/correct-all-revision';
import uncorrectAllRevisionQuery from 'accent-webapp/queries/uncorrect-all-revision';
import GlobalState from 'accent-webapp/services/global-state';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import IntlService from 'ember-intl/services/intl';
import {tracked} from '@glimmer/tracking';

const FLASH_MESSAGE_REVISION_CORRECT_SUCCESS =
  'pods.project.index.flash_messages.revision_correct_success';
const FLASH_MESSAGE_REVISION_CORRECT_ERROR =
  'pods.project.index.flash_messages.revision_correct_error';
const FLASH_MESSAGE_REVISION_CORRECT_FROM_VERSION_SUCCESS =
  'pods.project.index.flash_messages.revision_correct_from_version_success';
const FLASH_MESSAGE_REVISION_CORRECT_FROM_VERSION_ERROR =
  'pods.project.index.flash_messages.revision_correct_from_version_error';
const FLASH_MESSAGE_REVISION_UNCORRECT_SUCCESS =
  'pods.project.index.flash_messages.revision_uncorrect_success';
const FLASH_MESSAGE_REVISION_UNCORRECT_ERROR =
  'pods.project.index.flash_messages.revision_uncorrect_error';

export default class ProjectIndexController extends Controller {
  queryParams = ['document', 'version'];

  @tracked
  model: any;

  @tracked
  document: string | null = null;

  @tracked
  version: string | null = null;

  @service('global-state')
  declare globalState: GlobalState;

  @service('apollo-mutate')
  declare apolloMutate: ApolloMutate;

  @service('flash-messages')
  declare flashMessages: FlashMessages;

  @service('intl')
  declare intl: IntlService;

  @readOnly('globalState.permissions')
  permissions: any;

  @readOnly('model.project')
  project: any;

  @readOnly('project.revisions')
  revisions: any;

  @readOnly('project.mainRevisions')
  mainRevisions: any;

  @equal('model.project', undefined)
  emptyProject: boolean;

  @and('emptyProject', 'model.loading')
  showLoading: boolean;

  get documents() {
    return this.project?.documents?.entries || [];
  }

  get versions() {
    return this.project?.versions?.entries || [];
  }

  get selectedDocument() {
    if (!this.document) return this.documents[0];
    return this.documents.find((doc: {id: string}) => doc.id === this.document);
  }

  get showDocumentsSelect() {
    return this.documents.length > 1;
  }

  get showVersionsSelect() {
    return this.versions.length > 0;
  }

  @action
  changeDocument(select: HTMLSelectElement) {
    this.document = select.value || null;
  }

  @action
  changeVersion(select: HTMLSelectElement) {
    this.version = select.value || null;
  }

  @action
  async correctAllConflicts(revision: any) {
    const response = await this.apolloMutate.mutate({
      mutation: correctAllRevisionQuery,
      variables: {
        revisionId: revision.id,
        documentId: this.document || null,
        versionId: this.version || null
      },
      refetchQueries: ['Dashboard']
    });

    if (response.errors) {
      this.flashMessages.error(
        this.intl.t(FLASH_MESSAGE_REVISION_CORRECT_ERROR)
      );
    } else {
      this.flashMessages.success(
        this.intl.t(FLASH_MESSAGE_REVISION_CORRECT_SUCCESS)
      );
    }
  }

  @action
  async uncorrectAllConflicts(revision: any) {
    const response = await this.apolloMutate.mutate({
      mutation: uncorrectAllRevisionQuery,
      variables: {
        revisionId: revision.id,
        documentId: this.document || null,
        versionId: this.version || null
      },
      refetchQueries: ['Dashboard']
    });

    if (response.errors) {
      this.flashMessages.error(
        this.intl.t(FLASH_MESSAGE_REVISION_UNCORRECT_ERROR)
      );
    } else {
      this.flashMessages.success(
        this.intl.t(FLASH_MESSAGE_REVISION_UNCORRECT_SUCCESS)
      );
    }
  }

  @action
  async correctAllConflictsFromVersion(revision: any) {
    const response = await this.apolloMutate.mutate({
      mutation: correctAllRevisionQuery,
      variables: {
        revisionId: revision.id,
        documentId: this.document || null,
        versionId: null,
        fromVersionId: this.version
      },
      refetchQueries: ['Dashboard']
    });

    if (response.errors) {
      this.flashMessages.error(
        this.intl.t(FLASH_MESSAGE_REVISION_CORRECT_FROM_VERSION_ERROR)
      );
    } else {
      this.flashMessages.success(
        this.intl.t(FLASH_MESSAGE_REVISION_CORRECT_FROM_VERSION_SUCCESS)
      );
    }
  }
}
