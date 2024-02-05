import Component from '@glimmer/component';

interface Args {
  project: any;
  lintTranslations: any[];
  permissions: Record<string, true>;
}

interface Stat {
  title: string;
  count: number;
}

export default class LintTranslationsPage extends Component<Args> {
  get lintTranslationsStatsCount() {
    return this.lintTranslationsStats.reduce(
      (total, stat) => stat.count + total,
      0
    );
  }

  get lintTranslationsStats() {
    const stats = this.args.lintTranslations.reduce((acc, lintTranslation) => {
      lintTranslation.messages.forEach((message: {check: string}) => {
        if (acc[message.check]) {
          acc[message.check]++;
        } else {
          acc[message.check] = 1;
        }
      });

      return acc;
    }, {});

    return Object.entries(stats).map(([title, count]) => ({
      title,
      count,
    })) as Stat[];
  }
}
