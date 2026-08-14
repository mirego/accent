import Component from '@glimmer/component';
import {action} from '@ember/object';
import {tracked} from '@glimmer/tracking';
import Title from 'accent-webapp/components/project-settings/title/index';
import TerminalSvg from 'accent-webapp/svgs/assets/terminal.svg';
import t from 'ember-intl/helpers/t';
import {LinkTo} from '@ember/routing';
import {on} from '@ember/modifier';
import {fn} from '@ember/helper';
import eq from 'ember-truth-helpers/helpers/eq';

interface DocumentEntry {
  format: string;
  path: string;
}

interface Revision {
  isMaster: boolean;
  language: {
    slug: string;
  };
}

interface Project {
  id: string;
  name: string;
  documents?: {
    entries: DocumentEntry[];
  };
  revisions?: Revision[];
}

interface Args {
  project: Project;
}

type Workflow = 'sync' | 'export' | 'stats' | 'lint' | 'format' | 'jipt';

const commandKeys = ['sync', 'export', 'stats', 'lint', 'format', 'jipt'];

const workflowDescriptions: Record<Workflow, string> = {
  sync: 'components.project_settings.cli.workflow.sync',
  export: 'components.project_settings.cli.workflow.export',
  stats: 'components.project_settings.cli.workflow.stats',
  lint: 'components.project_settings.cli.workflow.lint',
  format: 'components.project_settings.cli.workflow.format',
  jipt: 'components.project_settings.cli.workflow.jipt'
};

const copyLabel = 'components.project_settings.cli.copy';
const copiedLabel = 'components.project_settings.cli.copied';

export default class ProjectSettingsCli extends Component<Args> {
  <template>
    <div class='project-settings-cli'>
      <section class='hero'>
        <div>
          <Title
            @icon={{TerminalSvg}}
            @title={{t 'components.project_settings.cli.title'}}
          />

          <p class='hero-text'>
            {{t 'components.project_settings.cli.intro' project=@project.name}}
          </p>

          <div class='hero-actions'>
            <a
              href='https://www.npmjs.com/package/accent-cli'
              target='_blank'
              rel='noopener noreferrer'
              class='button button--filled'
            >
              {{t 'components.project_settings.cli.npm_link'}}
            </a>

            <LinkTo
              @route='logged-in.project.edit.api-token'
              class='token-link'
            >
              {{t 'components.project_settings.cli.token_link'}}
            </LinkTo>
          </div>
        </div>

        <div class='terminal-card'>
          <div class='terminal-header'>
            <span></span>
            <span></span>
            <span></span>
          </div>

          <textarea
            readonly
            class='terminal'
            {{on 'click' this.selectText}}
          >{{this.setupCommand}}</textarea>
        </div>
      </section>

      <section class='section'>
        <div class='section-heading'>
          <h2>{{t 'components.project_settings.cli.config_title'}}</h2>
          <p>{{t 'components.project_settings.cli.config_text'}}</p>
        </div>

        <div class='code-panel'>
          <textarea
            readonly
            class='code code--config'
            {{on 'click' this.selectText}}
          >{{this.accentJson}}</textarea>
          <button
            type='button'
            class='copy-button copy-button--floating'
            {{on 'click' (fn this.copy this.accentJson 'config')}}
          >
            {{t this.configCopyLabel}}
          </button>
        </div>
      </section>

      <section class='section playground'>
        <div class='section-heading'>
          <h2>{{t 'components.project_settings.cli.playground_title'}}</h2>
          <p>{{t 'components.project_settings.cli.playground_text'}}</p>
        </div>

        <div class='playground-grid'>
          <div class='control-card'>
            <label for='accent-cli-workflow' class='label'>{{t
                'components.project_settings.cli.workflow_label'
              }}</label>
            <select
              id='accent-cli-workflow'
              class='select'
              {{on 'change' this.changeWorkflow}}
            >
              {{#each this.workflows as |workflow|}}
                <option
                  value={{workflow.value}}
                  selected={{eq workflow.value this.workflow}}
                >{{workflow.label}}</option>
              {{/each}}
            </select>

            <p class='workflow-description'>{{t
                this.playgroundDescriptionKey
              }}</p>
          </div>

          <div class='command-card'>
            <span class='prompt'>{{this.commandPrompt}}</span>
            <input
              readonly
              value={{this.playgroundCommand}}
              class='command'
              {{on 'click' this.selectText}}
            />
            <button
              type='button'
              class='copy-button'
              {{on 'click' (fn this.copy this.playgroundCommand 'command')}}
            >
              {{t this.commandCopyLabel}}
            </button>
          </div>
        </div>
      </section>

      <section class='section'>
        <div class='section-heading'>
          <h2>{{t 'components.project_settings.cli.commands_title'}}</h2>
          <p>{{t 'components.project_settings.cli.commands_text'}}</p>
        </div>

        <div class='commands-grid'>
          {{#each this.commands as |command|}}
            <article><code>{{command.command}}</code><span>{{t
                  command.descriptionKey
                }}</span></article>
          {{/each}}
        </div>
      </section>

      <section class='section'>
        <div class='section-heading'>
          <h2>{{t 'components.project_settings.cli.ci_title'}}</h2>
          <p>{{t 'components.project_settings.cli.ci_text'}}</p>
        </div>

        <div class='code-panel'>
          <textarea
            readonly
            class='code code--ci'
            {{on 'click' this.selectText}}
          >{{this.githubAction}}</textarea>
          <button
            type='button'
            class='copy-button copy-button--floating'
            {{on 'click' (fn this.copy this.githubAction 'ci')}}
          >
            {{t this.ciCopyLabel}}
          </button>
        </div>
      </section>
    </div>

    <style scoped>
      .project-settings-cli {
        margin-top: 30px;
      }

      .hero {
        display: grid;
        grid-template-columns: minmax(0, 1fr) minmax(360px, 510px);
        gap: 28px;
        align-items: flex-start;
      }

      .hero-text {
        max-width: 640px;
        margin: 14px 0 22px;
        font-size: 15px;
        line-height: 1.6;
        color: var(--text-color-normal);
      }

      .hero-actions {
        display: flex;
        flex-wrap: wrap;
        gap: 14px;
        align-items: center;
      }

      .token-link {
        color: var(--color-primary);
        font-size: 13px;
        font-weight: 700;
        text-decoration: none;
      }

      .terminal-card,
      .code-panel,
      .command-card,
      .control-card,
      .commands-grid article {
        border: 1px solid var(--content-background-border);
        border-radius: var(--border-radius);
        background: var(--content-background);
      }

      .terminal-card {
        position: relative;
        display: flex;
        flex-direction: column;
        min-height: 100%;
        background: #111;
        color: #ddd;
      }

      .terminal-header {
        display: flex;
        gap: 6px;
        padding: 8px 10px;
        background: rgba(255, 255, 255, 0.06);
      }
      .terminal-header span {
        width: 10px;
        height: 10px;
        border-radius: 50%;
      }
      .terminal-header span:global(:nth-child(1)) {
        background: rgb(255, 92, 95);
      }
      .terminal-header span:global(:nth-child(2)) {
        background: rgb(250, 200, 0);
      }
      .terminal-header span:global(:nth-child(3)) {
        background: rgb(52, 199, 89);
      }

      .terminal,
      .code,
      .command {
        font-family: var(--font-monospace);
        color: var(--text-color-normal);
      }

      .terminal {
        width: 100%;
        min-height: 160px;
        padding: 18px;
        border: 0;
        resize: none;
        background: transparent;
        color: #ddd;
        font-size: 13px;
        line-height: 1.7;
      }
      .terminal:focus {
        outline: none;
      }

      .playground-grid,
      .commands-grid {
        display: grid;
        gap: 16px;
      }

      .section {
        margin-top: 34px;
      }

      .section-heading {
        display: flex;
        flex-direction: column;
        gap: 4px;
        margin-bottom: 14px;
      }
      .section-heading h2 {
        margin: 0;
        font-size: 18px;
        font-weight: 700;
        color: var(--text-color-normal);
      }
      .section-heading p {
        max-width: 500px;
        margin: 0;
        font-size: 12px;
        line-height: 1.5;
        color: var(--color-grey);
      }

      .code-panel {
        position: relative;
        overflow: hidden;
      }

      .code {
        display: block;
        width: 100%;
        padding: 18px;
        border: 0;
        background: var(--background-light);
        font-size: 12px;
        line-height: 1.6;
        resize: none;
      }
      .code:focus {
        outline: none;
        box-shadow: inset 0 0 0 2px
          color-mix(in srgb, var(--color-primary) 45%, transparent);
      }

      .code--config {
        height: 230px;
      }

      .code--ci {
        height: 420px;
      }

      .playground-grid {
        grid-template-columns: 290px minmax(0, 1fr);
        align-items: flex-start;
      }

      .control-card,
      .command-card {
        padding: 16px;
      }

      .label {
        display: block;
        margin-bottom: 8px;
        font-size: 11px;
        font-weight: 700;
        color: var(--color-grey);
        text-transform: uppercase;
        letter-spacing: 0.08em;
      }

      .select {
        width: 100%;
        padding: 8px 10px;
        border: 1px solid var(--content-background-border);
        border-radius: var(--border-radius);
        background: var(--background-light);
        color: var(--text-color-normal);
        font-size: 13px;
      }

      .workflow-description {
        margin: 12px 0 0;
        font-size: 12px;
        line-height: 1.5;
        color: var(--color-grey);
      }

      .command-card {
        display: grid;
        grid-template-columns: auto minmax(0, 1fr) auto;
        gap: 10px;
        align-items: center;
        background: #111;
      }

      .prompt {
        color: color-mix(in srgb, var(--color-primary) 80%, #fff);
        font-family: var(--font-monospace);
        font-weight: 700;
      }

      .command {
        width: 100%;
        border: 0;
        background: transparent;
        color: #ddd;
        font-size: 13px;
      }
      .command:focus {
        outline: none;
      }

      .commands-grid {
        grid-template-columns: repeat(3, minmax(0, 1fr));
      }
      .commands-grid article {
        display: flex;
        flex-direction: column;
        gap: 4px;
        padding: 12px;
      }
      .commands-grid code {
        color: var(--color-primary);
        font-family: var(--font-monospace);
        font-size: 12px;
        font-weight: 700;
      }
      .commands-grid span {
        font-size: 12px;
        line-height: 1.3;
        color: var(--color-grey);
      }

      .copy-button {
        padding: 6px 10px;
        background: color-mix(in srgb, var(--color-primary) 12%, transparent);
        border-radius: var(--border-radius);
        color: var(--color-primary);
        font-size: 11px;
        font-weight: 700;
        cursor: pointer;
      }

      .copy-button--floating {
        position: absolute;
        top: 12px;
        right: 12px;
      }

      @media (max-width: 920px) {
        .hero,
        .playground-grid,
        .why-grid,
        .commands-grid {
          grid-template-columns: 1fr;
        }
        .section-heading {
          display: block;
        }
        .section-heading p {
          margin-top: 8px;
        }
      }
      @media (max-width: 560px) {
        .hero {
          padding: 16px;
        }
        .command-card {
          grid-template-columns: auto minmax(0, 1fr);
        }
        .command-card .copy-button {
          grid-column: 1/-1;
        }
      }
    </style>
  </template>
  @tracked
  workflow: Workflow = 'sync';

  @tracked
  copiedTarget = '';

  get workflows() {
    return [
      {value: 'sync', label: 'Sync'},
      {value: 'export', label: 'Export'},
      {value: 'stats', label: 'Stats'},
      {value: 'lint', label: 'Lint'},
      {value: 'format', label: 'Format'},
      {value: 'jipt', label: 'JIPT'}
    ];
  }

  get commands() {
    return commandKeys.map((key) => ({
      command: `accent ${key === 'jipt' ? 'jipt accent' : key}`,
      descriptionKey: `components.project_settings.cli.commands.${key}`
    }));
  }

  get host() {
    return window.location.origin;
  }

  get mainLanguageSlug() {
    const revision = this.args.project?.revisions?.find(
      (revision) => revision.isMaster
    );

    return revision?.language?.slug || 'en';
  }

  get firstDocument() {
    return this.args.project?.documents?.entries?.[0];
  }

  get exampleFormat() {
    return this.firstDocument?.format || 'json';
  }

  get exampleExtension() {
    if (this.firstDocument?.path?.includes('.'))
      return this.firstDocument.path.split('.').pop() || this.exampleFormat;

    return this.exampleFormat === 'gettext' ? 'po' : this.exampleFormat;
  }

  get sourcePattern() {
    return `locales/${this.mainLanguageSlug}/*.${this.exampleExtension}`;
  }

  get targetPattern() {
    return `locales/%slug%/%document_path%.${this.exampleExtension}`;
  }

  get accentJson() {
    return JSON.stringify(
      {
        apiUrl: this.host,
        project: this.args.project.id,
        files: [
          {
            format: this.exampleFormat,
            source: this.sourcePattern,
            target: this.targetPattern
          }
        ]
      },
      null,
      2
    );
  }

  get setupCommand() {
    return [
      'npm install -g accent-cli',
      `export ACCENT_API_URL="${this.host}"`,
      'export ACCENT_API_KEY="..."',
      `export ACCENT_PROJECT="${this.args.project.id}"`,
      'accent sync --add-translations'
    ].join('\n');
  }

  get playgroundCommand() {
    switch (this.workflow) {
      case 'export':
        return 'accent export --order-by=key';
      case 'stats':
        return 'accent stats --check-reviewed --check-translated';
      case 'lint':
        return 'accent lint --path .';
      case 'format':
        return 'accent format --order-by=key';
      case 'jipt':
        return 'accent jipt accent';
      case 'sync':
      default:
        return 'accent sync --dry-run --sync-type=passive';
    }
  }

  get commandPrompt() {
    return '$';
  }

  get configCopyLabel() {
    return this.copiedTarget === 'config' ? copiedLabel : copyLabel;
  }

  get commandCopyLabel() {
    return this.copiedTarget === 'command' ? copiedLabel : copyLabel;
  }

  get ciCopyLabel() {
    return this.copiedTarget === 'ci' ? copiedLabel : copyLabel;
  }

  get playgroundDescriptionKey() {
    return workflowDescriptions[this.workflow];
  }

  get githubAction() {
    return `name: Accent

on:
  schedule:
    - cron: "0 4 * * *"
  workflow_dispatch:

jobs:
  accent:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
      - run: npm install -g accent-cli
      - run: accent sync --add-translations --merge-type=passive --order-by=key
        env:
          ACCENT_API_URL: ${this.host}
          ACCENT_API_KEY: \${{ secrets.ACCENT_API_KEY }}
          ACCENT_PROJECT: ${this.args.project.id}
      - uses: mirego/create-pull-request@v5
        with:
          add-paths: "*.json"
          commit-message: Update translations
          committer: github-actions[bot] <github-actions[bot]@users.noreply.github.com>
          author: github-actions[bot] <github-actions[bot]@users.noreply.github.com>
          branch: accent
          draft: false
          delete-branch: true
          title: New translations are available to merge
          body: The translation files have been updated, feel free to merge this pull request after review.`;
  }

  @action
  changeWorkflow(event: Event) {
    this.workflow = (event.target as HTMLSelectElement).value as Workflow;
  }

  @action
  selectText(event: Event) {
    (event.target as HTMLTextAreaElement | HTMLInputElement).select();
  }

  @action
  async copy(text: string, target: string) {
    if (navigator.clipboard) {
      const copied = await navigator.clipboard.writeText(text).then(
        () => true,
        () => false
      );

      if (copied) {
        this.copiedTarget = target;
        return;
      }
    }

    const textarea = document.createElement('textarea');

    textarea.value = text;
    textarea.style.position = 'fixed';
    textarea.style.opacity = '0';
    document.body.appendChild(textarea);
    textarea.select();
    document.execCommand('copy');
    textarea.remove();
    this.copiedTarget = target;
  }
}
