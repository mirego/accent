import Component from '@glimmer/component';
import t from 'ember-intl/helpers/t';
import AccBadge from 'accent-webapp/components/acc-badge/index';
import Item from 'accent-webapp/components/translations-list/item/index';
import EmptyHero from 'accent-webapp/components/empty-hero/index';

interface Args {
  project: any;
  version: any;
  versions: any[];
  revisionId: string;
  translations: any;
  withAdvancedFilters: boolean;
  query: string;
  onUpdateText: (translation: any, editText: string) => Promise<void>;
}

export default class TranslationsList extends Component<Args> {
  <template>
    {{#if this.currentVersion}}
      <div class='translations-list-version'>
        {{t 'components.translations_list.translations_version_notice'}}
        <AccBadge @version={{true}}>
          <span
            class='translations-list-version-tag'
          >{{this.currentVersion.tag}}</span>
        </AccBadge>
      </div>
    {{/if}}

    {{#if this.hasTranslations}}
      <ul class='translations-list'>
        {{#each @translations key='id' as |translation|}}
          <Item
            @translation={{translation}}
            @revisions={{@revisions}}
            @prompts={{@prompts}}
            @permissions={{@permissions}}
            @project={{@project}}
            @onUpdateText={{@onUpdateText}}
          />
        {{/each}}
      </ul>
    {{else if @query}}
      <EmptyHero
        @title={{t
          'components.translations_list.no_translations_filters_title'
        }}
        @text={{t
          'components.translations_list.no_translations_query'
          query=@query
        }}
      />
    {{else if @withAdvancedFilters}}
      <EmptyHero
        @title={{t
          'components.translations_list.no_translations_filters_title'
        }}
        @text={{t 'components.translations_list.no_translations_filters'}}
      />
    {{else}}
      <EmptyHero
        @title={{t 'components.translations_list.no_translations_title'}}
        @text={{t 'components.translations_list.no_translations'}}
      />
    {{/if}}

    <style scoped>
      .translations-list {
        margin-top: 10px;
      }

      .translations-list-version {
        margin: 0 0 15px;
        padding: 15px;
        border-radius: var(--border-radius);
        font-size: 12px;
        background: hsl(
          var(--color-blue-hue),
          var(--color-blue-saturation),
          var(--color-highlight-lighteness)
        );
        color: var(--color-blue);
      }

      .translations-list-version-tag {
        display: inline-flex;
        align-items: center;
        margin-left: 2px;
        font-size: 11px;
        font-family: var(--font-monospace);
        font-weight: 600;
        text-transform: none;
      }
    </style>
  </template>
  get hasTranslations() {
    return Boolean(this.args.translations?.length);
  }

  get currentVersion() {
    if (!this.args.versions) return;
    if (!this.args.version) return;

    return this.args.versions.find(
      (version) => version.id === this.args.version,
    );
  }
}
