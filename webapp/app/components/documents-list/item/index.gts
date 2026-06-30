import {action} from '@ember/object';
import {not} from '@ember/object/computed';
import {service} from '@ember/service';
import Component from '@glimmer/component';
import percentage from 'accent-webapp/component-helpers/percentage';
import GlobalState from 'accent-webapp/services/global-state';
import {tracked} from '@glimmer/tracking';
import {on} from '@ember/modifier';
import {fn, array, get} from '@ember/helper';
import t from 'ember-intl/helpers/t';
import {htmlSafe} from '@ember/template';
import onKey from 'ember-keyboard/modifiers/on-key';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import {scopedClass} from 'ember-scoped-css';
import {LinkTo} from '@ember/routing';
import ReviewProgressBar from 'accent-webapp/components/review-progress-bar/index';
import AsyncButton from 'accent-webapp/components/async-button/index';

const LOW_PERCENTAGE = 50;
const HIGH_PERCENTAGE = 90;

interface Args {
  permissions: Record<string, true>;
  document: any;
  project: any;
  onDelete: (documentEntity: any) => Promise<void>;
  onUpdate: (documentEntity: any, path: string) => Promise<void>;
}

export default class DocumentsListItem extends Component<Args> {
  <template>
    <li
      class='documents-list-item
        {{if this.isEditing "editing"}}
        {{if this.empty "empty"}}
        {{if this.lowPercentage "low-percentage"}}
        {{if this.mediumPercentage "medium-percentage"}}
        {{if this.highPercentage "high-percentage"}}'
    >
      <form
        class='item-form {{if this.isDeleting "item-form--deleting"}}'
        {{on 'submit' (fn this.updateDocument)}}
      >
        <div class='item-form-content'>

          {{#if this.empty}}
            <span class='removed-badge'>
              {{t 'components.documents_list.item.removed_label'}}
            </span>
          {{/if}}
          <div class='item-form-inputs'>
            <h2 class='item-title'>
              {{#if this.isEditing}}
                <label class='item-form-label'>
                  {{t 'components.documents_list.item.path_label'}}
                  <small class='item-form-help'>
                    {{htmlSafe (t 'components.documents_list.item.path_help')}}
                  </small>

                  <input
                    value={{this.renamedDocumentPath}}
                    class='textInput'
                    {{onKey 'cmd+Enter' (fn this.updateDocument)}}
                    {{on 'input' (fn this.changePath)}}
                  />
                </label>
              {{else}}
                <span class='item-toggle-edit'>
                  {{#if this.isDeleting}}
                    <span class='item-document-deleting-title'>
                      {{inlineSvg
                        '/assets/loading.svg'
                        class=(scopedClass
                          'item-document-deleting-title-loading'
                        )
                      }}

                      {{t
                        'components.documents_list.item.deleting_label'
                        path=@document.path
                        extension=this.documentFormatItem.extension
                      }}
                    </span>
                  {{else}}
                    <button
                      class='item-edit-button'
                      {{on 'click' (fn this.toggleEdit)}}
                    >
                      {{inlineSvg
                        'assets/pencil.svg'
                        class=(scopedClass 'item-edit-icon')
                      }}
                    </button>

                    <LinkTo
                      @route='logged-in.project.files.export'
                      @models={{array @project.id @document.id}}
                      class='item-document'
                    >
                      {{@document.path}}
                    </LinkTo>
                  {{/if}}
                </span>
              {{/if}}
            </h2>
          </div>

          {{#if this.showStats}}
            <div class='stat'>
              <span class='reviewedPercentage'>
                {{this.correctedKeysPercentage}}
                %
              </span>
              <span class='reviewedStats'>
                <span class='reviewedStats-reviewedCount'>
                  {{this.reviewsCount}}
                </span>
                /
                <span class='reviewedStats-translationsCount'>
                  {{@document.translationsCount}}
                </span>
              </span>
            </div>

            <div class='progress'>
              <ReviewProgressBar
                @correctedKeysPercentage={{this.correctedKeysPercentage}}
              />
            </div>
          {{/if}}
        </div>

        {{#if this.isEditing}}
          <div class='links links--editing'>
            <AsyncButton
              class='button button--filled'
              @loading={{this.isUpdating}}
              @onClick={{fn this.updateDocument}}
            >
              {{t 'components.documents_list.save_button'}}
            </AsyncButton>
            <button
              class='button button--filled button--white'
              {{on 'click' (fn this.toggleEdit)}}
            >
              {{t 'components.documents_list.cancel_button'}}
            </button>
          </div>
        {{else}}
          {{#unless this.empty}}
            <div class='links'>
              {{#if (get @permissions 'sync')}}
                <LinkTo
                  @route='logged-in.project.files.sync'
                  @models={{array @project.id @document.id}}
                  class='button button--filled button-sync'
                >
                  {{inlineSvg '/assets/sync.svg' class='button-icon'}}
                  {{t 'components.documents_list.sync'}}
                </LinkTo>
              {{/if}}
              {{#if this.multipleRevisions}}
                {{#if (get @permissions 'merge')}}
                  <LinkTo
                    @route='logged-in.project.files.add-translations'
                    @models={{array @project.id @document.id}}
                    class='button button--filled button--white'
                  >
                    {{inlineSvg '/assets/merge.svg' class='button-icon'}}
                    {{t 'components.documents_list.merge'}}
                  </LinkTo>
                {{/if}}
              {{/if}}
              {{#if (get @permissions 'machineTranslationsTranslate')}}
                <LinkTo
                  @route='logged-in.project.files.machine-translations'
                  @models={{array @project.id @document.id}}
                  class='button button--filled button--white'
                >
                  {{inlineSvg '/assets/language.svg' class='button-icon'}}
                  {{t 'components.documents_list.machine_translations'}}
                </LinkTo>
              {{/if}}
              {{#if (get @permissions 'exportRevision')}}
                <LinkTo
                  @route='logged-in.project.files.export'
                  @models={{array @project.id @document.id}}
                  class='button button--filled button--white'
                >
                  {{inlineSvg '/assets/export.svg' class='button-icon'}}
                  {{t 'components.documents_list.export'}}
                </LinkTo>
              {{/if}}
            </div>

            <div class='deleteDocumentButton-container'>
              {{#if (get @permissions 'deleteDocument')}}
                {{#if this.canDeleteFile}}
                  <AsyncButton
                    @onClick={{fn this.deleteFile @document}}
                    @loading={{this.isDeleting}}
                    title={{t 'components.documents_list.delete_document'}}
                    class='tooltip tooltip--top button button--small button--red button--borderless button--iconOnly deleteDocumentButton'
                  >
                    {{inlineSvg '/assets/x.svg' class='button-icon'}}
                  </AsyncButton>
                {{/if}}
              {{/if}}
            </div>
          {{/unless}}
        {{/if}}
      </form>
    </li>
  </template>
  @service('global-state')
  declare globalState: GlobalState;

  @tracked
  renamedDocumentPath = this.args.document.path;

  @not('project.lockedFileOperations')
  canDeleteFile: boolean;

  @tracked
  isEditing = false;

  @tracked
  isDeleting = false;

  @tracked
  isUpdating = false;

  get multipleRevisions() {
    return (
      this.args.project.revisions && this.args.project.revisions.length > 1
    );
  }

  get lowPercentage() {
    return this.correctedKeysPercentage < LOW_PERCENTAGE;
  }

  get mediumPercentage() {
    return this.correctedKeysPercentage >= LOW_PERCENTAGE;
  }

  get highPercentage() {
    return this.correctedKeysPercentage >= HIGH_PERCENTAGE;
  }

  get documentFormatItem() {
    if (!this.globalState.documentFormats) return {};

    return this.globalState.documentFormats.find(({slug}) => {
      return slug === this.args.document.format;
    });
  }

  get empty() {
    return this.args.document.translationsCount === 0;
  }

  get showStats() {
    return !this.empty && !this.isEditing;
  }

  get correctedKeysPercentage() {
    return percentage(
      this.args.document.translationsCount - this.args.document.conflictsCount,
      this.args.document.translationsCount
    );
  }

  get reviewsCount() {
    const {conflictsCount, translationsCount} = this.args.document;

    return translationsCount - conflictsCount;
  }

  @action
  async deleteFile(document: any) {
    this.isDeleting = true;

    await this.args.onDelete(document);

    this.isDeleting = false;
  }

  @action
  toggleEdit() {
    this.isEditing = !this.isEditing;
  }

  @action
  changePath(event: KeyboardEvent) {
    const target = event.target as HTMLInputElement;
    this.renamedDocumentPath = target.value;
  }

  @action
  async updateDocument(event?: Event) {
    event?.preventDefault();

    this.isUpdating = true;

    await this.args.onUpdate(this.args.document, this.renamedDocumentPath);

    this.isUpdating = false;
    this.isEditing = false;
  }
}
