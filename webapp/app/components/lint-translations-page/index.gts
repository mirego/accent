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
import or from 'ember-truth-helpers/helpers/or';
import {on} from '@ember/modifier';
import {fn, concat, get} from '@ember/helper';
import t from 'ember-intl/helpers/t';
import eq from 'ember-truth-helpers/helpers/eq';
import perform from 'ember-concurrency/helpers/perform';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import didUpdate from '@ember/render-modifiers/modifiers/did-update';
import Item from 'accent-webapp/components/lint-translations-page/item/index';
import didInsert from '@ember/render-modifiers/modifiers/did-insert';
import willDestroy from '@ember/render-modifiers/modifiers/will-destroy';

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
  <template>
    <div class='content'>
      {{#if (or @lintTranslations @checkFilter)}}
        <div class='stats-wrapper'>
          <div class='stats'>
            <button
              type='button'
              class='stats-item {{unless @checkFilter "stats-item--active"}}'
              {{on 'click' (fn @onChangeCheckFilter null)}}
            >
              <span>{{t
                  'components.translation_edit.lint_message.title_checks.all'
                }}</span>
              <strong>{{this.lintTranslationsStatsCount}}</strong>
            </button>

            {{#each this.lintTranslationsStats as |stat|}}
              <button
                type='button'
                class='stats-item
                  {{if (eq @checkFilter stat.title) "stats-item--active"}}'
                {{on 'click' (fn @onChangeCheckFilter stat.title)}}
              >
                <span>{{t
                    (concat
                      'components.translation_edit.lint_message.title_checks.'
                      stat.title
                    )
                  }}</span>
                <strong>{{stat.count}}</strong>
              </button>
            {{/each}}
          </div>

          {{#if (get @permissions 'updateTranslation')}}
            <button
              type='button'
              class='button button--borderless button--green fix-all'
              disabled={{this.fixingAll}}
              {{on 'click' (perform this.fixAllTask)}}
            >
              {{inlineSvg 'assets/check-circle.svg' class='button-icon'}}
              {{#if this.fixingAll}}
                {{t 'components.lint_translations_page.fixing_all'}}
              {{else}}
                {{t 'components.lint_translations_page.fix_all'}}
              {{/if}}
            </button>
          {{/if}}
        </div>
      {{/if}}

      {{#if @lintTranslations}}
        <div {{didUpdate this.resetVisibleCount @lintTranslations}}>
          {{#each
            this.visibleLintTranslations key='translation.id'
            as |lintTranslation|
          }}
            <div
              class='item
                {{if
                  (eq
                    this.fixLintMessageRunningTranslationId
                    lintTranslation.translation.id
                  )
                  "item--fixing"
                }}'
            >
              <Item
                @permissions={{@permissions}}
                @project={{@project}}
                @lintTranslation={{lintTranslation}}
                @createLintEntry={{perform this.createLintEntryTask}}
                @fixText={{perform this.fixLintMessageTask}}
              />
            </div>
          {{/each}}

          {{#if this.hasMore}}
            <div
              class='sentinel'
              {{didInsert this.observeSentinel}}
              {{willDestroy this.unobserveSentinel}}
            ></div>
          {{/if}}
        </div>
      {{else}}
        <div class='all-good'>
          <img
            src='/assets/all-reviewed-splash.svg'
            class='all-reviewed-image'
          />

          <div class='all-good-title'>
            {{t 'components.lint_translations_page.empty_title'}}
          </div>

          <div class='all-good-subtitle'>
            {{t 'components.lint_translations_page.empty_text'}}
          </div>
        </div>
      {{/if}}
    </div>
  </template>
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
