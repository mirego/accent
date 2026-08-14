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
import ExportSvg from 'accent-webapp/svgs/assets/export.svg';
import LanguageSvg from 'accent-webapp/svgs/assets/language.svg';
import LoadingSvg from 'accent-webapp/svgs/assets/loading.svg';
import MergeSvg from 'accent-webapp/svgs/assets/merge.svg';
import PencilSvg from 'accent-webapp/svgs/assets/pencil.svg';
import SyncSvg from 'accent-webapp/svgs/assets/sync.svg';
import XSvg from 'accent-webapp/svgs/assets/x.svg';
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
                      <LoadingSvg
                        class={{scopedClass
                          'item-document-deleting-title-loading'
                        }}
                      />

                      {{t
                        'components.documents_list.item.deleting_label'
                        path=@document.path
                        extension=this.documentFormatItem.extension
                      }}
                    </span>
                  {{else}}
                    <button
                      type='button'
                      class='item-edit-button'
                      {{on 'click' (fn this.toggleEdit)}}
                    >
                      <PencilSvg class={{scopedClass 'item-edit-icon'}} />
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
              type='button'
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
                  <SyncSvg class='button-icon' />
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
                    <MergeSvg class='button-icon' />
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
                  <LanguageSvg class='button-icon' />
                  {{t 'components.documents_list.machine_translations'}}
                </LinkTo>
              {{/if}}
              {{#if (get @permissions 'exportRevision')}}
                <LinkTo
                  @route='logged-in.project.files.export'
                  @models={{array @project.id @document.id}}
                  class='button button--filled button--white'
                >
                  <ExportSvg class='button-icon' />
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
                    <XSvg class='button-icon' />
                  </AsyncButton>
                {{/if}}
              {{/if}}
            </div>
          {{/unless}}
        {{/if}}
      </form>
    </li>

    <style scoped>
      .textInput {
        transition: 0.2s ease-in-out;
        transition-property: background, border, box-shadow;
        resize: vertical;
        outline: 0;
        border-radius: var(--border-radius);
        border: 2px solid var(--input-border-color);
        background: var(--input-background);
        color: var(--input-color);
        font-family: var(--font-monospace);
        line-height: 1.4;
        max-height: 200px;
      }
      .textInput::-moz-selection {
        background: color-mix(in srgb, var(--color-primary) 70%, transparent);
      }
      .textInput::selection {
        background: color-mix(in srgb, var(--color-primary) 70%, transparent);
      }
      .textInput:focus {
        border: 2px solid var(--color-primary);
      }
      .textInput:disabled {
        color: var(--color-grey);
        background: var(--background-light);
      }

      @media (hover: none) and (max-width: 640px) {
        .textInput {
          font-size: 16px !important;
        }
      }
      .documents-list-item {
        position: relative;
        display: flex;
        width: 100%;
        padding: 10px 0;
      }
      .documents-list-item:hover .deleteDocumentButton {
        opacity: 1;
      }

      .documents-list-item.empty {
        padding: 0 6px 4px;
        margin-left: -6px;
        margin-bottom: 10px;
        width: calc(100% - 6px);
        background: var(--body-background);
        border-radius: var(--border-radius);
      }
      .documents-list-item.empty.editing {
        padding: 0;
        background: transparent;
        border-radius: 0;
        margin-left: 0;
      }
      .documents-list-item.empty.editing .removed-badge {
        display: none;
      }

      .documents-list-item.low-percentage .reviewedPercentage {
        color: var(--color-error);
      }
      .documents-list-item.low-percentage .progress {
        color: var(--color-error);
      }

      .documents-list-item.medium-percentage .reviewedPercentage {
        color: var(--color-warning);
      }
      .documents-list-item.medium-percentage .progress {
        color: var(--color-warning);
      }

      .documents-list-item.high-percentage .reviewedPercentage {
        color: var(--color-success);
      }
      .documents-list-item.high-percentage .progress {
        color: var(--color-success);
      }

      .item-form--deleting {
        opacity: 0.7;
        cursor: not-allowed;
        pointer-events: none;
      }
      .item-form--deleting .deleteDocumentButton {
        opacity: 0;
      }

      .stat {
        display: flex;
        align-items: center;
        justify-content: space-between;
        font-size: 12px;
      }

      .progress {
        margin: 3px 0 10px;
      }

      .reviewedStats {
        padding: 2px 0 1px 7px;
        color: var(--color-black);
        font-family: var(--font-monospace);
      }

      .reviewedPercentage {
        margin-right: 10px;
        font-size: 18px;
      }

      .item-title {
        display: inline-flex;
        width: 100%;
        font-size: 15px;
        margin-left: -2px;
      }

      .removed-badge {
        font-size: 11px;
        opacity: 0.4;
      }

      .textInput {
        padding: 5px 8px 4px;
        width: 100%;
        font-size: 15px;
        font-family: var(--font-primary);
      }

      .item-document-deleting-title {
        display: flex;
        color: var(--color-error);
        font-size: 13px;
      }

      .item-document-deleting-title-loading {
        width: 10px;
        margin-right: 6px;
        fill: var(--color-error);
      }

      .item-form {
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        width: 100%;
      }
      .item-form.item-form--editing {
        padding: 15px;
        box-shadow: 0 1px 5px var(--shadow-color);
      }

      .item-form-content {
        flex-grow: 1;
        margin-right: 30px;
      }

      .item-form-label {
        display: block;
        margin-bottom: 8px;
        font-size: 13px;
      }

      .item-form-help {
        display: block;
        margin-bottom: 6px;
        font-size: 11px;
        color: #bbb;
      }
      .item-form-help em {
        margin: 0 2px;
        padding: 0 2px;
        border: 1px solid var(--background-light-border);
        border-radius: var(--border-radius);
        background: var(--background-light);
        font-family: var(--font-monospace);
        font-style: normal;
        color: #777;
      }

      .item-form-inputs {
        width: 100%;
      }

      .item-toggle-edit {
        position: relative;
        left: -24px;
        padding-left: 37px;
      }
      .item-toggle-edit:focus .item-edit-icon,
      .item-toggle-edit:hover .item-edit-icon {
        opacity: 1;
      }

      .item-document {
        margin-left: -26px;
        text-decoration: none;
        color: var(--color-black);
      }

      .item-edit-button {
        background: transparent;
      }
      .item-edit-button:hover {
        outline: none;
      }

      .item-edit-icon {
        position: absolute;
        left: 0;
        top: 4px;
        width: 16px;
        height: 16px;
        opacity: 0;
        stroke: #ccc;
        transition: 0.2s ease-in-out;
        transition-property: opacity, stroke;
      }
      .item-edit-icon:focus,
      .item-edit-icon:hover {
        stroke: #aaa;
      }

      .links {
        display: flex;
        flex-wrap: wrap;
        flex-shrink: 1;
        justify-content: space-between;
      }
      .links :global(.button) {
        margin-right: 6px;
      }
      .links
        :global(.button):global(
          .button--borderLess
        ):first-of-type:last-of-type {
        margin-left: -14px;
      }

      .links--editing {
        width: 100%;
        justify-content: flex-start;
        transform: translate3d(0, 0, 0);
      }

      .deleteDocumentButton-container {
        display: flex;
        align-items: center;
        padding-left: 5px;
      }

      .deleteDocumentButton {
        opacity: 0;
        padding: 2px 6px !important;
      }

      @media (max-width: 1300px) {
        .links {
          transform: translate3d(0, 0, 0);
        }
      }
      @media (max-width: 800px) {
        .item {
          margin-right: 0;
          width: 100%;
        }
      }
    </style>
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
