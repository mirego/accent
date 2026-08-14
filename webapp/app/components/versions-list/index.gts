import Component from '@glimmer/component';
import {service} from '@ember/service';
import EmptyHero from 'accent-webapp/components/empty-hero/index';
import Item from 'accent-webapp/components/versions-list/item/index';
import t from 'ember-intl/helpers/t';
import IntlService from 'ember-intl/services/intl';
import MergeSvg from 'accent-webapp/svgs/assets/merge.svg';
import ShareSvg from 'accent-webapp/svgs/assets/share.svg';
import SyncSvg from 'accent-webapp/svgs/assets/sync.svg';
import TerminalSvg from 'accent-webapp/svgs/assets/terminal.svg';

interface Args {
  permissions: Record<string, true>;
  versions: any;
  project: any;
  onDelete: (versionEntity: any) => Promise<void>;
}

export default class VersionsList extends Component<Args> {
  <template>
    {{#if @versions}}
      <ul class='versions-list'>
        {{#each @versions key='id' as |version|}}
          <Item
            @permissions={{@permissions}}
            @version={{version}}
            @project={{@project}}
            @onDelete={{@onDelete}}
          />
        {{/each}}
      </ul>
    {{else}}
      <EmptyHero
        @title={{t 'components.versions_list.empty_title'}}
        @text={{t 'components.versions_list.empty_text'}}
        @features={{this.features}}
      />
    {{/if}}

    <style scoped>
      .versions-list {
        display: flex;
        flex-direction: column;
        width: 100%;
        padding-bottom: 20px;
        margin: 20px 0;
        border-bottom: 1px solid var(--background-light-highlight);
      }
    </style>
  </template>
  @service('intl')
  declare intl: IntlService;

  get features() {
    return [
      {
        icon: SyncSvg,
        title: this.intl.t(
          'components.versions_list.empty_feature_independent_title'
        ),
        text: this.intl.t(
          'components.versions_list.empty_feature_independent_text'
        )
      },
      {
        icon: ShareSvg,
        title: this.intl.t(
          'components.versions_list.empty_feature_integrations_title'
        ),
        text: this.intl.t(
          'components.versions_list.empty_feature_integrations_text'
        )
      },
      {
        icon: TerminalSvg,
        title: this.intl.t('components.versions_list.empty_feature_cli_title'),
        text: this.intl.t('components.versions_list.empty_feature_cli_text')
      },
      {
        icon: MergeSvg,
        title: this.intl.t(
          'components.versions_list.empty_feature_sync_back_title'
        ),
        text: this.intl.t(
          'components.versions_list.empty_feature_sync_back_text'
        )
      }
    ];
  }
}
