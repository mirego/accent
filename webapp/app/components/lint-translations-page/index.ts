import {service} from '@ember/service';
import {action} from '@ember/object';
import {tracked} from '@glimmer/tracking';
import Component from '@glimmer/component';
import {restartableTask} from 'ember-concurrency';
import IntlService from 'ember-intl/services/intl';
import FlashMessages from 'ember-cli-flash/services/flash-messages';
import translationUpdateQuery from 'accent-webapp/queries/update-translation';
import fixLintTranslationsQuery from 'accent-webapp/queries/fix-lint-translations';
import projectLintEntryCreateQuery from 'accent-webapp/queries/create-project-lint-entry';
import Apollo from 'accent-webapp/services/apollo';
import ApolloMutate from 'accent-webapp/services/apollo-mutate';

const ADD_LINT_ENTRY_FLASH_MESSAGE_PREFIX =
  'components.lint_translations_page.add_lint_entry.flash_messages.';

interface Args {
  project: any;
  lintTranslations: any[];
  lintChecks: Array<{check: string; count: number}>;
  permissions: Record<string, true>;
  checkFilter: string | null;
  revisionId: string | null;
  query: string;
  onChangeCheckFilter: (check: string | null) => void;
}

interface Stat {
  title: string;
  count: number;
}

const INITIAL_VISIBLE_COUNT = 50;
const VISIBLE_COUNT_INCREMENT = 50;

export default class LintTranslationsPage extends Component<Args> {
  @service('apollo')
  declare apollo: Apollo;

  @service('apollo-mutate')
  declare apolloMutate: ApolloMutate;

  @service('intl')
  declare intl: IntlService;

  @service('flash-messages')
  declare flashMessages: FlashMessages;

  @tracked
  fixLintMessageRunningTranslationId: string | null = null;

  @tracked
  fixingAll = false;

  @tracked
  visibleCount = INITIAL_VISIBLE_COUNT;

  intersectionObserver: IntersectionObserver | null = null;

  get visibleLintTranslations() {
    return (this.args.lintTranslations || []).slice(0, this.visibleCount);
  }

  get hasMore() {
    return (this.args.lintTranslations || []).length > this.visibleCount;
  }

  @action
  resetVisibleCount() {
    this.visibleCount = INITIAL_VISIBLE_COUNT;
  }

  @action
  observeSentinel(element: Element) {
    this.intersectionObserver = new IntersectionObserver((entries) => {
      if (entries.some((entry) => entry.isIntersecting)) {
        this.visibleCount += VISIBLE_COUNT_INCREMENT;
      }
    });

    this.intersectionObserver.observe(element);
  }

  @action
  unobserveSentinel() {
    this.intersectionObserver?.disconnect();
    this.intersectionObserver = null;
  }

  willDestroy() {
    super.willDestroy();
    this.unobserveSentinel();
  }

  get lintTranslationsStatsCount() {
    return this.lintTranslationsStats.reduce(
      (total, stat) => stat.count + total,
      0
    );
  }

  get lintTranslationsStats() {
    return (this.args.lintChecks || []).map((stat) => ({
      title: stat.check,
      count: stat.count
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

  fixAllTask = restartableTask(async () => {
    this.fixingAll = true;

    await this.apollo.client.mutate({
      mutation: fixLintTranslationsQuery,
      refetchQueries: ['Lint'],
      variables: {
        projectId: this.args.project.id,
        revisionId: this.args.revisionId,
        check: this.args.checkFilter,
        query: this.args.query
      }
    });

    this.fixingAll = false;
    this.args.onChangeCheckFilter(null);
  });

  createLintEntryTask = restartableTask(async (lintEntry: any) => {
    const response = await this.apolloMutate.mutate({
      mutation: projectLintEntryCreateQuery,
      refetchQueries: ['Lint'],
      variables: {
        projectId: this.args.project.id,
        checkIds: lintEntry.checkIds,
        type: lintEntry.type,
        value: lintEntry.value
      }
    });

    if (response.errors) {
      this.flashMessages.error(
        this.intl.t(`${ADD_LINT_ENTRY_FLASH_MESSAGE_PREFIX}create_error`)
      );
    } else {
      this.flashMessages.success(
        this.intl.t(`${ADD_LINT_ENTRY_FLASH_MESSAGE_PREFIX}create_success`)
      );
    }

    return response;
  });
}
