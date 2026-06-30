import {tracked} from '@glimmer/tracking';
import {action} from '@ember/object';
import Component from '@glimmer/component';
import t from 'ember-intl/helpers/t';
import Group from 'accent-webapp/components/conflicts-list/group/index';

interface Args {
  permissions: Record<string, true>;
  project: any;
  groupedTranslations: any;
  groupedRevisions: any;
  version: any;
  versions: any[];
  query: any;
  onCorrect: (conflict: any, textInput: string) => Promise<void>;
  onCopyTranslation: (
    text: string,
    sourceLanguageSlug: string,
    targetLanguageSlug: string
  ) => void;
}

export default class ConflictsList extends Component<Args> {
  <template>
    {{#if this.currentVersion}}
      <div class='conflicts-list-version'>

        {{t 'components.conflicts_list.translations_version_notice'}}
        <span
          class='conflicts-list-version-tag'
        >{{this.currentVersion.tag}}</span>
      </div>
    {{/if}}

    <div
      style='--group-columns-count: {{@groupedRevisions.length}};'
      class='conflicts-wrapper'
    >
      {{#if @groupedTranslations}}
        <ul class='conflicts-header'>
          {{#each this.mappedRevisions as |revision|}}
            <li class='conflicts-header-item'>
              {{revision.name}}
              <span class='conflicts-header-item-slug'>
                {{revision.slug}}
              </span>
            </li>
          {{/each}}
        </ul>
      {{/if}}

      <ul class='conflicts-items'>
        {{#each @groupedTranslations key='key' as |groupedTranslation index|}}
          <Group
            @index={{index}}
            @permissions={{@permissions}}
            @project={{@project}}
            @prompts={{@prompts}}
            @groupedTranslation={{groupedTranslation}}
            @onCorrect={{@onCorrect}}
            @onUncorrect={{@onUncorrect}}
            @onUpdate={{@onUpdate}}
            @selectedTranslationId={{this.selectedTranslationId}}
            @onFocus={{this.handleFocus}}
          />
        {{else}}
          <div class='all-reviewed'>
            <img
              src='/assets/all-reviewed-splash.svg'
              class='all-reviewed-image'
            />

            <div class='all-reviewed-title'>
              {{t 'components.conflicts_list.all_reviewed_title'}}
            </div>

            <div class='all-reviewed-subtitle'>
              {{t 'components.conflicts_list.all_reviewed_subtitle'}}
            </div>
          </div>
        {{/each}}
      </ul>
    </div>
  </template>
  @tracked
  selectedTranslationId: string | null = null;

  get currentVersion() {
    if (!this.args.versions) return;
    if (!this.args.version) return;

    return this.args.versions.find(
      (version) => version.id === this.args.version
    );
  }

  get mappedRevisions() {
    return this.args.groupedRevisions.map((revision: any) => {
      return {
        name: revision.name || revision.language.name,
        slug: revision.slug || revision.language.slug
      };
    });
  }

  @action
  handleFocus(id: string) {
    this.selectedTranslationId = id;
  }
}
