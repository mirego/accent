import {action} from '@ember/object';
import {service} from '@ember/service';
import {equal} from '@ember/object/computed';
import Component from '@glimmer/component';
import IntlService from 'ember-intl/services/intl';
import GlobalState from 'accent-webapp/services/global-state';
import {tracked} from '@glimmer/tracking';
import t from 'ember-intl/helpers/t';
import AccSelect from 'accent-webapp/components/acc-select/index';
import {fn, get, concat} from '@ember/helper';
import {Input} from '@ember/component';
import {on} from '@ember/modifier';
import AsyncButton from 'accent-webapp/components/async-button/index';
import FileInput from 'accent-webapp/components/file-input/index';
import FolderSvg from 'accent-webapp/svgs/assets/folder.svg';
import ImportSvg from 'accent-webapp/svgs/assets/import.svg';
import CommitFileInstructions from 'accent-webapp/components/commit-file-instructions/index';
import {scopedClass} from 'ember-scoped-css';

const DEFAULT_PROPERTIES = {
  isFileReading: false,
  isFileRead: false,
  isPeeking: false,
  isPeekingDone: false,
  isPeekingError: false,
  isCommiting: false,
  isCommitingDone: false,
  isCommitingError: false,

  file: null,
  fileSource: null,
  documentPath: null,
  documentFormat: 'json'
};

interface Args {
  permissions: Record<string, true>;
  versions: any;
  revisions: any;
  documents: any;
  canCommit: boolean;
  commitAction: 'merge' | 'sync';
  peekAction: 'peekMerge' | 'peekSync';
  commitButtonText: string;
  onFileCancel: () => void;
  onPeek: (options: {
    fileSource: any;
    documentPath: string | null;
    documentFormat: any;
    version: any;
    revision: any;
    mergeType: string;
    syncType: string;
    mergeOptions: string[];
  }) => Promise<void>;
  onCommit: (options: {
    fileSource: any;
    documentPath: string | null;
    documentFormat: any;
    revision: any;
    version: any;
    mergeType: string;
    syncType: string;
    mergeOptions: string[];
  }) => Promise<void>;
}

export default class CommitFile extends Component<Args> {
  <template>
    <div class='commit-file'>
      {{#if this.isPeekingError}}
        <div class='errorMessage'>
          {{t 'components.commit_file.peek_error'}}
        </div>
      {{/if}}
      {{#if this.isCommitingError}}
        <div class='errorMessage'>
          {{t 'components.commit_file.commit_error'}}
        </div>
      {{/if}}
      {{#if this.isMerge}}
        {{#if this.file}}
          <div class='options'>
            <div class='option option--borderless'>
              <p class='textHelper'>
                {{t 'components.commit_file.language'}}
                :
              </p>
              <AccSelect
                @searchEnabled={{false}}
                @selected={{this.revisionValue}}
                @options={{this.mappedRevisions}}
                @onchange={{fn this.onSelectRevision}}
              />
            </div>
            <div class='option option--borderless'>
              <p class='textHelper'>
                {{t 'components.commit_file.commit_type'}}
                :
              </p>
              <AccSelect
                @searchEnabled={{false}}
                @selected={{this.mergeType}}
                @options={{this.mappedMergeTypes}}
                @onchange={{fn this.onSelectMergeType}}
              />
            </div>
          </div>
        {{/if}}
      {{/if}}
      {{#if this.isSync}}
        {{#if this.file}}
          <div class='options'>
            <div class='option option--borderless'>
              <p class='textHelper'>
                {{t 'components.commit_file.commit_type'}}
                :
              </p>
              <AccSelect
                @searchEnabled={{false}}
                @selected={{this.syncType}}
                @options={{this.mappedSyncTypes}}
                @onchange={{fn this.onSelectSyncType}}
              />
            </div>
            <div class='option option--borderless'></div>
          </div>
        {{/if}}
      {{/if}}

      {{#if this.file}}
        <div>
          {{#if @documents}}
            {{#if this.isSync}}
              <div class='option'>
                <p class='textHelper'>
                  {{t 'components.commit_file.file_source'}}
                </p>
                <p>
                  {{#if this.existingDocumentPath}}
                    <span class='documentHelper'>
                      {{t 'components.commit_file.existing_document_warning'}}
                    </span>
                  {{else}}
                    <span class='documentHelper documentHelper--new'>
                      {{t 'components.commit_file.new_document_warning'}}
                    </span>
                  {{/if}}
                </p>
                <Input @value={{this.documentPath}} class='fileSourceName' />
              </div>
            {{/if}}
          {{/if}}

          <div class='option'>
            <p class='textHelper'>
              {{t 'components.commit_file.document_format'}}
            </p>
            <AccSelect
              @searchEnabled={{false}}
              @selected={{this.documentFormatValue}}
              @options={{this.documentFormatOptions}}
              @onchange={{fn this.onSelectDocumentFormat}}
            />
          </div>

          {{#if this.hasVersions}}
            <div class='option'>
              <p class='textHelper'>
                {{t 'components.commit_file.version_tag'}}
              </p>
              <AccSelect
                @searchEnabled={{false}}
                @selected={{this.versionValue}}
                @options={{this.mappedVersions}}
                @onchange={{fn this.onSelectVersion}}
              />
            </div>
          {{/if}}

          {{#if this.isMerge}}
            <div class='option'>
              <p class='textHelper'>
                {{t 'components.commit_file.merge_options'}}
              </p>

              <label class='optionLabel'>
                <input
                  type='checkbox'
                  checked={{this.correctOnMerge}}
                  {{on 'change' (fn this.onChangeCorrectOnMerge)}}
                />
                <span class='optionLabelText'>
                  {{t 'components.commit_file.correct_on_merge'}}
                </span>
              </label>
            </div>
          {{/if}}

          {{#if (get @permissions @peekAction)}}
            <div class='option'>
              <p class='textHelper'>
                {{t 'components.commit_file.peek_help'}}
              </p>
              <AsyncButton
                @onClick={{fn this.peek}}
                @loading={{this.isPeeking}}
                class='button button--filled button--blue peekButton'
              >
                {{t 'components.commit_file.peek_button'}}
              </AsyncButton>
            </div>
          {{/if}}

          {{#if (get @permissions @commitAction)}}
            <div class='actions'>
              <AsyncButton
                @onClick={{fn this.fileCancel}}
                class='button button--filled button--white'
              >
                {{t 'components.commit_file.cancel_button'}}
              </AsyncButton>

              {{#if @canCommit}}
                <AsyncButton
                  @onClick={{fn this.commit}}
                  @loading={{this.isCommiting}}
                  class='button button--filled'
                >
                  {{@commitButtonText}}
                </AsyncButton>
              {{else}}
                <AsyncButton class='button button--filled button--disabled'>
                  {{@commitButtonText}}
                </AsyncButton>
              {{/if}}
            </div>
          {{/if}}
        </div>
      {{else}}
        <div class='emptyFile'>
          <div class='emptyFile-upload'>
            <FileInput
              name='file-input'
              id='file-input'
              @onChange={{this.fileChange}}
              class='fileInput'
            />

            <strong class='fileInputTitle'>
              <FolderSvg class={{scopedClass 'fileInputIcon'}} />
              {{t 'components.commit_file.upload_title'}}
            </strong>

            <p class='fileInputHelper'>
              {{t 'components.commit_file.upload_help'}}
            </p>

            <label for='file-input' class='button button--filled fileButton'>
              <ImportSvg
                class={{concat
                  'button-icon'
                  ' '
                  (scopedClass 'local-button-icon')
                }}
              />
              {{t 'components.commit_file.file_input_button'}}
            </label>
          </div>

          <CommitFileInstructions />
        </div>
      {{/if}}
    </div>

    <style scoped>
      .fileSourceName,
      .commit-file :global(.textInput) {
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
      .fileSourceName::-moz-selection,
      .commit-file :global(.textInput)::-moz-selection {
        background: color-mix(in srgb, var(--color-primary) 70%, transparent);
      }
      .fileSourceName::selection,
      .commit-file :global(.textInput)::selection {
        background: color-mix(in srgb, var(--color-primary) 70%, transparent);
      }
      .fileSourceName:focus,
      .commit-file :focus:global(.textInput) {
        border: 2px solid var(--color-primary);
      }
      .fileSourceName:disabled,
      .commit-file :disabled:global(.textInput) {
        color: var(--color-grey);
        background: var(--background-light);
      }

      @media (hover: none) and (max-width: 640px) {
        .fileSourceName,
        .commit-file :global(.textInput) {
          font-size: 16px !important;
        }
      }
      .commit-file :global(.textInput) {
        margin-bottom: 8px;
        padding: 5px;
        outline: 0;
        background: #fff;
        font-family: var(--font-monospace);
        font-size: 12px;
      }
      .commit-file :global(.ember-power-select-trigger) {
        padding: 6px 10px;
        border: 1px solid var(--background-light-highlight);
        background: var(--background-light);
        color: var(--color-black-opacity-70);
      }

      .textHelper {
        margin-bottom: 3px;
        width: 80%;
        color: var(--color-grey);
        font-size: 12px;
      }

      .documentHelper {
        display: inline-block;
        margin-bottom: 7px;
        padding: 2px 0 3px;
        border-radius: var(--border-radius);
        color: var(--color-primary);
        font-size: 11px;
      }
      .documentHelper.documentHelper--new {
        color: var(--color-green);
      }

      .options {
        display: flex;
        padding: 0;
        margin: 0;
        font-size: 13px;
      }
      .options .option {
        padding-top: 0;
      }

      .option {
        flex: 1 1 auto;
        width: 100%;
        padding: 9px 0;
        margin: 0;
      }
      .option.option--borderless {
        border-bottom: 0;
      }
      .option.option--borderless:first-of-type {
        margin-right: 10px;
      }

      .optionLabel {
        display: flex;
        font-size: 12px;
      }

      .optionLabelText {
        margin-left: 5px;
      }

      .actions {
        margin-top: 15px;
      }

      .fileInput {
        opacity: 0;
        overflow: hidden;
        position: absolute;
        z-index: -1;
        pointer-events: none;
      }

      .fileInputIcon {
        width: 15px;
        height: 15px;
        margin-right: 10px;
        stroke: var(--color-black);
        stroke: var(--color-black);
      }

      .fileInputTitle {
        display: flex;
        align-items: center;
        margin: 0 0 6px;
        color: var(--color-black);
        color: var(--color-black);
      }

      .fileInputHelper {
        max-width: 300px;
        margin: 0 0 10px;
        font-size: 14px;
        font-weight: 300;
        color: var(--color-black-opacity-70);
      }

      .fileButton {
        align-self: center !important;
        margin-top: 7px !important;
        padding: 9px 30px !important;
      }
      .fileButton .local-button-icon {
        margin-right: 10px !important;
      }

      .emptyFile {
        display: flex;
      }
      .emptyFile:global(> div:first-of-type) {
        width: 35%;
        flex-shrink: 0;
      }

      .emptyFile-upload {
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        text-align: center;
      }

      .peekButton {
        margin-top: 7px !important;
      }

      .errorMessage {
        margin: 10px 0;
        color: var(--color-error);
        font-size: 13px;
        font-weight: bold;
      }

      .fileSourceName {
        padding: 6px 10px;
        font-size: 12px;
        font-family: var(--font-monospace);
        color: #444;
      }
    </style>
  </template>
  @service('intl')
  declare intl: IntlService;

  @service('global-state')
  declare globalState: GlobalState;

  @equal('args.commitAction', 'merge')
  isMerge: boolean;

  @equal('args.commitAction', 'sync')
  isSync: boolean;

  mergeTypes = ['smart', 'passive', 'force'];
  syncTypes = ['smart', 'passive'];

  @tracked
  isFileReading = DEFAULT_PROPERTIES.isFileReading;

  @tracked
  isFileRead = DEFAULT_PROPERTIES.isFileRead;

  @tracked
  isPeeking = DEFAULT_PROPERTIES.isPeeking;

  @tracked
  isPeekingDone = DEFAULT_PROPERTIES.isPeekingDone;

  @tracked
  isPeekingError = DEFAULT_PROPERTIES.isPeekingError;

  @tracked
  isCommiting = DEFAULT_PROPERTIES.isCommiting;

  @tracked
  isCommitingDone = DEFAULT_PROPERTIES.isCommitingDone;

  @tracked
  isCommitingError = DEFAULT_PROPERTIES.isCommitingError;

  @tracked
  file: ProgressEvent<FileReader> | null = DEFAULT_PROPERTIES.file;

  @tracked
  fileSource: File | null = DEFAULT_PROPERTIES.fileSource;

  @tracked
  documentPath: string | null = DEFAULT_PROPERTIES.documentPath;

  @tracked
  documentFormat: string | null = DEFAULT_PROPERTIES.documentFormat;

  @tracked
  mergeType = this.mappedMergeTypes[0];

  @tracked
  syncType = this.mappedSyncTypes[0];

  @tracked
  correctOnMerge = false;

  @tracked
  revision =
    this.args.commitAction === 'merge' && this.args.revisions[1]
      ? this.args.revisions[1]
      : this.args.revisions.find((revision: any) => revision.isMaster);

  @tracked
  revisionValue =
    this.mappedRevisions.find(
      ({value}) => value === (this.revision && this.revision.id)
    ) || this.mappedRevisions[0];

  @tracked
  version: {id: string; tag: string} | null = null;

  @tracked
  versionValue =
    this.mappedVersions.find(
      ({value}) => value === (this.version && this.version.id)
    ) || this.mappedVersions[0];

  get mappedRevisions(): Array<{label: string; value: string}> {
    return this.args.revisions.map(
      ({id, language}: {id: string; language: {name: string}}) => ({
        label: language.name,
        value: id
      })
    );
  }

  get hasVersions() {
    return this.args.versions.length > 0;
  }

  get mappedMergeTypes() {
    return this.mergeTypes.map((name) => ({
      label: this.intl.t(`components.commit_file.commit_types.${name}`),
      value: name
    }));
  }

  get mappedSyncTypes() {
    return this.syncTypes.map((name) => ({
      label: this.intl.t(`components.commit_file.commit_types.${name}`),
      value: name
    }));
  }

  get mappedVersions(): Array<{label: string; value: string}> {
    return [
      {
        label: this.intl.t('components.commit_file.no_version_label'),
        value: null
      },
      ...this.args.versions.map(({id, tag}: {id: string; tag: string}) => ({
        label: tag,
        value: id
      }))
    ];
  }

  get documentFormatValue() {
    return this.documentFormatOptions.find(({value}) => {
      return value === this.documentFormat;
    });
  }

  get documentFormatOptions(): Array<{value: string; label: string}> {
    if (!this.globalState.documentFormats) return [];

    return this.globalState.documentFormats.map(({slug, name}) => ({
      value: slug,
      label: name
    }));
  }

  get existingDocumentPath() {
    if (!this.documentPath) return false;
    if (!this.args.documents) return false;

    const path = this.documentPath.replace(/\..+/, '');

    return this.args.documents.find((document: any) => document.path === path);
  }

  @action
  onSelectMergeType(mergeType: {label: string; value: string}) {
    this.mergeType = mergeType;
  }

  @action
  onSelectSyncType(syncType: {label: string; value: string}) {
    this.syncType = syncType;
  }

  @action
  onSelectRevision(revision: {label: string; value: string}) {
    this.revision = this.args.revisions.find(
      ({id}: {id: string}) => id === revision.value
    );

    this.revisionValue = revision;
  }

  @action
  onSelectVersion(version: {label: string; value: string}) {
    this.version = this.args.versions.find(
      ({id}: {id: string}) => id === version.value
    );

    this.versionValue = version;
  }

  @action
  onSelectDocumentFormat(documentFormat: {label: string; value: string}) {
    this.documentFormat = documentFormat.value;
  }

  @action
  onChangeCorrectOnMerge() {
    this.correctOnMerge = !this.correctOnMerge;
  }

  @action
  async commit() {
    this.onCommiting();

    try {
      await this.args.onCommit({
        fileSource: this.fileSource,
        documentPath: this.documentPath,
        documentFormat: this.documentFormat,
        version: this.version && this.version.tag,
        revision: this.revision,
        mergeType: this.mergeType.value,
        syncType: this.syncType.value,
        mergeOptions: this.correctOnMerge ? ['correct'] : []
      });

      this.onCommitingDone();
    } catch (error) {
      this.onCommitingError();
    }
  }

  @action
  async peek() {
    this.onPeeking();

    try {
      await this.args.onPeek({
        fileSource: this.fileSource,
        documentPath: this.documentPath,
        documentFormat: this.documentFormat,
        revision: this.revision,
        version: this.version && this.version.tag,
        mergeType: this.mergeType.value,
        syncType: this.syncType.value,
        mergeOptions: this.correctOnMerge ? ['correct'] : []
      });

      this.onPeekingDone();
    } catch (error) {
      this.onPeekingError();
    }
  }

  @action
  fileChange(files: File[]) {
    const fileSource = files[0];
    const filename = fileSource.name.split('.');
    const fileExtension = filename.pop();

    const documentPath = filename.join('.');
    const documentFormat = this.formatFromExtension(fileExtension);
    const isFileReading = true;
    const isFileRead = false;
    const reader = new FileReader();

    this.fileSource = fileSource;
    this.documentPath = documentPath;
    this.isFileReading = isFileReading;
    this.isFileRead = isFileRead;
    this.documentFormat = documentFormat;

    reader.onload = this.fileRead.bind(this);
    reader.readAsText(files[0]);
  }

  @action
  fileCancel() {
    this.args.onFileCancel();

    this.initProperties();
  }

  private formatFromExtension(fileExtension?: string) {
    if (!this.globalState.documentFormats) return null;

    const documentFormatItem = this.globalState.documentFormats.find(
      ({extension}) => {
        return extension === fileExtension;
      }
    );

    return documentFormatItem
      ? documentFormatItem.slug
      : this.globalState.documentFormats[0].slug;
  }

  private async fileRead(event: ProgressEvent<FileReader>) {
    this.isFileReading = false;
    this.isFileRead = true;
    this.file = event;

    await this.peek();
  }

  private onCommiting() {
    this.isCommiting = true;
    this.isCommitingDone = false;
    this.isCommitingError = false;
    this.isPeekingError = false;
  }

  private onCommitingDone() {
    this.isCommiting = false;
    this.isCommitingDone = true;
  }

  private onCommitingError() {
    this.isCommiting = false;
    this.isCommitingError = true;
  }

  private onPeeking() {
    this.isPeeking = true;
    this.isPeekingDone = false;
    this.isPeekingError = false;
    this.isCommitingError = false;
  }

  private onPeekingDone() {
    this.isPeeking = false;
    this.isPeekingDone = true;
  }

  private onPeekingError() {
    this.isPeeking = false;
    this.isPeekingError = true;
  }

  private initProperties() {
    this.isFileReading = DEFAULT_PROPERTIES.isFileReading;
    this.isFileRead = DEFAULT_PROPERTIES.isFileRead;
    this.isPeeking = DEFAULT_PROPERTIES.isPeeking;
    this.isPeekingDone = DEFAULT_PROPERTIES.isPeekingDone;
    this.isPeekingError = DEFAULT_PROPERTIES.isPeekingError;
    this.isCommiting = DEFAULT_PROPERTIES.isCommiting;
    this.isCommitingDone = DEFAULT_PROPERTIES.isCommitingDone;
    this.isCommitingError = DEFAULT_PROPERTIES.isCommitingError;
    this.file = DEFAULT_PROPERTIES.file;
    this.fileSource = DEFAULT_PROPERTIES.fileSource;
    this.documentPath = DEFAULT_PROPERTIES.documentPath;
    this.documentFormat = DEFAULT_PROPERTIES.documentFormat;
  }
}
