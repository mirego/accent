import Component from '@glimmer/component';

export default class ProjectFileOperation extends Component {
  <template>
    <div class='project-file-operation'>
      {{yield}}
    </div>

    <style scoped>
      .project-file-operation {
        position: relative;
        background: var(--content-background);
      }
      .project-file-operation :global(.closeButton) {
        position: absolute;
        top: 10px;
        right: 10px;
        padding: 0;
        background: transparent;
      }
      .project-file-operation :global(.closeButton):focus .closeButton-icon,
      .project-file-operation :global(.closeButton):hover .closeButton-icon {
        stroke: var(--color-error);
      }
      .project-file-operation :global(.closeButton-content) {
        display: flex;
      }
      .project-file-operation :global(.closeButton-icon) {
        width: 25px;
        height: 25px;
        color: var(--text-color-normal);
        opacity: 0.5;
      }
      .project-file-operation :global(.sectionType) {
        display: flex;
        align-items: center;
        font-size: 16px;
        font-weight: bold;
        color: var(--color-primary);
      }
      .project-file-operation :global(.sectionType-icon) {
        width: 18px;
        height: 18px;
        margin-right: 4px;
        stroke: var(--color-primary);
      }
      .project-file-operation :global(.versionTitle) {
        display: flex;
        align-items: center;
      }
      .project-file-operation :global(.versionTitle-name) {
        color: var(--color-primary);
      }
      .project-file-operation :global(.versionTitle-tag) {
        display: inline-flex;
        align-items: center;
        margin-left: 10px;
        font-family: var(--font-monospace);
        font-size: 14px;
        font-weight: normal;
        color: #888;
      }
      .project-file-operation :global(.versionTitle-tag-icon) {
        width: 12px;
        height: 12px;
        stroke: #bbb;
      }
      .project-file-operation :global(.title) {
        display: flex;
        padding: 12px 20px 12px 12px;
        background: var(--content-background);
        border-bottom: 1px solid var(--background-light-highlight);
        font-size: 15px;
      }
      .project-file-operation :global(.title-document) {
        display: flex;
        align-items: baseline;
        margin-left: 10px;
        font-size: 16px;
      }
      .project-file-operation :global(.title-documentExtension) {
        font-size: 14px;
        color: var(--color-grey);
      }
      .project-file-operation :global(.subtitle) {
        font-size: 13px;
        font-weight: bold;
      }
      .project-file-operation :global(.subtitle-label) {
        font-size: 11px;
        font-weight: normal;
        color: #333;
      }
      .project-file-operation :global(.renderExport) {
        position: absolute;
        top: 10px;
        right: 50px;
      }
      .project-file-operation :global(.toggleJiptExport) {
        position: absolute;
        top: 13px;
        right: 130px;
      }
      .project-file-operation :global(.sections) {
        display: flex;
      }
      .project-file-operation :global(.sections-file) {
        flex: 1 1 40%;
        padding: 20px;
      }
      .project-file-operation :global(.sections-preview) {
        flex: 1 1 60%;
        padding: 20px;
      }
      .project-file-operation :global(.sections-preview-title) {
        font-size: 13px;
        color: var(--color-grey);
      }
      .project-file-operation :global(.sections-preview-empty) {
        padding: 30px 10px;
        margin: 10px 0 0;
        background: #fafafa;
        border: 1px solid #eee;
        text-align: center;
        font-size: 13px;
        font-style: italic;
        color: var(--color-grey);
      }

      @media (max-width: 800px) {
        .project-file-operation :global(.sections) {
          flex-direction: column;
        }
      }
    </style>
  </template>
}
