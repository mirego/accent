import Component from '@glimmer/component';
import {action} from '@ember/object';
import {tracked} from '@glimmer/tracking';

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
