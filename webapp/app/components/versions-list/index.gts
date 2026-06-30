import Component from '@glimmer/component';
import Item from 'accent-webapp/components/versions-list/item/index';
import t from 'ember-intl/helpers/t';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import {scopedClass} from 'ember-scoped-css';

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
      <div class='empty'>
        <div class='empty-hero'>
          <div>
            <h3 class='empty-hero-title'>{{t
                'components.versions_list.empty_title'
              }}</h3>
            <p class='empty-hero-text'>{{t
                'components.versions_list.empty_text'
              }}</p>
          </div>
        </div>

        <ul class='empty-features'>
          <li class='empty-feature'>
            {{inlineSvg
              '/assets/sync.svg'
              class=(scopedClass 'empty-feature-icon')
            }}
            <div>
              <strong>{{t
                  'components.versions_list.empty_feature_independent_title'
                }}</strong>
              <span>{{t
                  'components.versions_list.empty_feature_independent_text'
                }}</span>
            </div>
          </li>

          <li class='empty-feature'>
            {{inlineSvg
              '/assets/share.svg'
              class=(scopedClass 'empty-feature-icon')
            }}
            <div>
              <strong>{{t
                  'components.versions_list.empty_feature_integrations_title'
                }}</strong>
              <span>{{t
                  'components.versions_list.empty_feature_integrations_text'
                }}</span>
            </div>
          </li>

          <li class='empty-feature'>
            {{inlineSvg
              '/assets/terminal.svg'
              class=(scopedClass 'empty-feature-icon')
            }}
            <div>
              <strong>{{t
                  'components.versions_list.empty_feature_cli_title'
                }}</strong>
              <span>{{t
                  'components.versions_list.empty_feature_cli_text'
                }}</span>
            </div>
          </li>

          <li class='empty-feature'>
            {{inlineSvg
              '/assets/merge.svg'
              class=(scopedClass 'empty-feature-icon')
            }}
            <div>
              <strong>{{t
                  'components.versions_list.empty_feature_sync_back_title'
                }}</strong>
              <span>{{t
                  'components.versions_list.empty_feature_sync_back_text'
                }}</span>
            </div>
          </li>
        </ul>
      </div>
    {{/if}}
  </template>
}
