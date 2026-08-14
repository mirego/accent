import Component from '@glimmer/component';
import Overview from 'accent-webapp/components/project-settings/manage-languages/overview/index';
import {get} from '@ember/helper';
import CreateForm from 'accent-webapp/components/project-settings/manage-languages/create-form/index';
import CheckSvg from 'accent-webapp/svgs/assets/check.svg';
import MergeSvg from 'accent-webapp/svgs/assets/merge.svg';
import SyncSvg from 'accent-webapp/svgs/assets/sync.svg';
import {scopedClass} from 'ember-scoped-css';
import t from 'ember-intl/helpers/t';

interface Args {
  project: any;
  revisions: any;
  permissions: Record<string, true>;
  languages: any;
  errors: any;
  onPromoteMaster: () => void;
  onDelete: () => void;
  onCreate: () => void;
}

export default class ManageLanguages extends Component<Args> {
  <template>
    <div class='project-settings-manage-languages'>
      <div class='overview'>
        <Overview
          @permissions={{@permissions}}
          @project={{@project}}
          @revisions={{@revisions}}
          @onPromoteMaster={{@onPromoteMaster}}
          @onDelete={{@onDelete}}
        />

        {{#if (get @permissions 'createSlave')}}
          <div class='createSlaveForm'>
            {{#if @errors}}
              <ul class='error'>
                {{#each @errors as |error|}}
                  <li>
                    {{error}}
                  </li>
                {{/each}}
              </ul>
            {{/if}}
            <CreateForm
              @permissions={{@permissions}}
              @project={{@project}}
              @languages={{@languages}}
              @onCreate={{@onCreate}}
            />
          </div>
        {{/if}}
      </div>

      <div class='help'>
        <div class='helpItem'>
          <span class='helpItem-icon'>
            <SyncSvg class={{scopedClass 'helpItem-iconSvg'}} />
          </span>
          <div class='helpItem-body'>
            <h2 class='helpItem-title'>
              {{t 'components.project_manage_languages.sync_explain_title'}}
            </h2>
            <p class='helpItem-text'>
              {{t 'components.project_manage_languages.sync_explain_text'}}
            </p>
          </div>
        </div>

        <div class='helpItem'>
          <span class='helpItem-icon'>
            <MergeSvg class={{scopedClass 'helpItem-iconSvg'}} />
          </span>
          <div class='helpItem-body'>
            <h2 class='helpItem-title'>
              {{t
                'components.project_manage_languages.add_translations_explain_title'
              }}
            </h2>
            <p class='helpItem-text'>
              {{t
                'components.project_manage_languages.add_translations_explain_text'
              }}
            </p>
          </div>
        </div>

        <div class='helpItem'>
          <span class='helpItem-icon'>
            <CheckSvg class={{scopedClass 'helpItem-iconSvg'}} />
          </span>
          <div class='helpItem-body'>
            <h2 class='helpItem-title'>
              {{t
                'components.project_manage_languages.conflicts_explain_title'
              }}
            </h2>
            <p class='helpItem-text'>
              {{t 'components.project_manage_languages.conflicts_explain_text'}}
            </p>
          </div>
        </div>
      </div>
    </div>

    <style scoped>
      .project-settings-manage-languages {
        display: flex;
        gap: 40px;
        align-items: flex-start;
        margin-top: 24px;
      }

      .overview {
        flex: 1 1 45%;
        min-width: 0;
      }

      .help {
        display: flex;
        flex: 1 1 55%;
        flex-direction: column;
        gap: 20px;
        min-width: 0;
      }

      .helpItem {
        display: flex;
        gap: 14px;
        align-items: flex-start;
      }

      .helpItem-icon {
        display: inline-flex;
        flex-shrink: 0;
        align-items: center;
        justify-content: center;
        box-sizing: content-box;
        width: 16px;
        height: 16px;
        padding: 9px;
        border-radius: var(--border-radius);
        color: var(--color-primary);
        background: color-mix(in srgb, var(--color-primary) 12%, transparent);
      }
      .helpItem-iconSvg {
        width: 16px;
        height: 16px;
        stroke: var(--color-primary);
      }

      .helpItem-body {
        display: flex;
        flex-direction: column;
        gap: 3px;
      }

      .helpItem-title {
        margin: 0;
        font-size: 14px;
        font-weight: 700;
        color: var(--text-color-normal);
      }

      .helpItem-text {
        margin: 0;
        max-width: 640px;
        font-size: 13px;
        line-height: 1.5;
        color: color-mix(in srgb, var(--text-color-normal) 60%, transparent);
      }

      .emptyLanguages {
        font-size: 14px;
        padding: 10px;
        background: var(--background-light);
        border-radius: var(--border-radius);
        color: var(--color-black);
      }

      .createSlaveForm {
        margin-top: 20px;
      }

      .error {
        margin-bottom: 10px;
        font-size: 12px;
        font-weight: bold;
        color: var(--color-error);
      }

      @media (max-width: 640px) {
        .project-settings-manage-languages {
          flex-direction: column;
          gap: 28px;
        }
      }
    </style>
  </template>
}
