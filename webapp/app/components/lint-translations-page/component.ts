import {inject as service} from '@ember/service';
import {tracked} from '@glimmer/tracking';
import Component from '@glimmer/component';
import {restartableTask} from 'ember-concurrency';
import translationUpdateQuery from 'accent-webapp/queries/update-translation';
import projectLintEntryCreateQuery from 'accent-webapp/queries/create-project-lint-entry';
import Apollo from 'accent-webapp/services/apollo';

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
  @service('apollo')
  apollo: Apollo;

  @tracked
  fixLintMessageRunningTranslationId: string | null = null;

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
      count
    })) as Stat[];
  }

  fixLintMessageTask = restartableTask(
    async (translation: {id: string}, message: any) => {
      this.fixLintMessageRunningTranslationId = translation.id;

      await this.apollo.client.mutate({
        mutation: translationUpdateQuery,
        refetchQueries: ['Lint'],
        variables: {
          text: message.replacement.value,
          translationId: translation.id
        }
      });

      this.fixLintMessageRunningTranslationId = null;
    }
  );

  createLintEntryTask = restartableTask(async (lintEntry: any) => {
    await this.apollo.client.mutate({
      mutation: projectLintEntryCreateQuery,
      refetchQueries: ['Lint'],
      variables: {
        projectId: this.args.project.id,
        checkIds: lintEntry.checkIds,
        type: lintEntry.type,
        value: lintEntry.value
      }
    });
  });
}
