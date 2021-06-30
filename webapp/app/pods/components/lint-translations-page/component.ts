import Component from '@glimmer/component';

interface Args {
  project: any;
  lintTranslations: any[];
  permissions: Record<string, true>;
}

export default class LintTranslationsPage extends Component<Args> {}
