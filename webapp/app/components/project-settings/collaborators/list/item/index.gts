import {action} from '@ember/object';
import {notEmpty} from '@ember/object/computed';
import {service} from '@ember/service';
import Component from '@glimmer/component';
import Session from 'accent-webapp/services/session';
import IntlService from 'ember-intl/services/intl';
import {tracked} from '@glimmer/tracking';
import GlobalState from 'accent-webapp/services/global-state';
import AccSelect from 'accent-webapp/components/acc-select/index';
import {fn} from '@ember/helper';
import AccAvatarImg from 'accent-webapp/components/acc-avatar-img/index';
import t from 'ember-intl/helpers/t';
import TimeAgoInWordsTag from 'accent-webapp/components/time-ago-in-words-tag/index';
import {on} from '@ember/modifier';
import inlineSvg from 'accent-webapp/helpers/inline-svg';

interface Args {
  permissions: Record<string, true>;
  collaborator: any;
  onDelete: (collaborator: any) => void;
  onUpdate: (collaborator: any, args: any) => Promise<void>;
}

export default class CollaboratorsListItem extends Component<Args> {
  <template>
    <li
      data-test-collaborator
      class='item
        {{if this.isEditing "editing"}}
        {{if this.hasJoined "joined" "invited"}}
        {{if @collaborator.user.pictureUrl "withPicture"}}'
    >
      <div class='item-content'>
        <div>
          {{#if this.isEditing}}
            <div class='role-edit'>
              <AccSelect
                @searchEnabled={{false}}
                @selected={{this.roleValue}}
                @options={{this.mappedPossibleRoles}}
                @onchange={{fn this.setRole}}
              />
            </div>
          {{/if}}

          <span class='user'>
            {{#if @collaborator.user.pictureUrl}}
              <AccAvatarImg
                src={{@collaborator.user.pictureUrl}}
                class='user-picture'
              />
            {{/if}}

            <span class='user-name'>
              {{#if this.hasJoined}}
                {{#if @collaborator.user.fullname}}
                  <span data-test-collaborator-fullname class='fullname'>
                    {{@collaborator.user.fullname}}
                    {{#unless this.isEditing}}
                      <span class='role'>
                        {{this.role}}
                      </span>
                    {{/unless}}
                  </span>

                  <small data-test-collaborator-email class='user-email'>
                    {{@collaborator.email}}
                  </small>
                {{else}}
                  <span data-test-collaborator-email class='fullname'>
                    {{@collaborator.email}}
                    {{#unless this.isEditing}}
                      <span class='role'>
                        {{this.role}}
                      </span>
                    {{/unless}}
                  </span>
                {{/if}}
              {{else}}
                <span data-test-collaborator-email class='fullname'>
                  {{@collaborator.email}}
                  {{#unless this.isEditing}}
                    <span class='role'>
                      {{this.role}}
                    </span>
                  {{/unless}}
                </span>
              {{/if}}
            </span>
          </span>
        </div>

        <div>
          <span class='invite'>
            {{#if this.hasJoined}}
              {{t 'components.project_settings.collaborators_item.joined'}}
              <TimeAgoInWordsTag @date={{@collaborator.insertedAt}} />
            {{else}}
              {{t 'components.project_settings.collaborators_item.invited'}}

              <TimeAgoInWordsTag @date={{@collaborator.insertedAt}} />

              {{#if @collaborator.assigner}}
                {{t 'components.project_settings.collaborators_item.by'}}
                {{@collaborator.assigner.fullname}}
              {{/if}}
            {{/if}}
          </span>
        </div>
      </div>

      <div class='actions'>
        {{#if this.isEditing}}
          {{#if this.canUpdateCollaborator}}
            <button
              class='button button--filled button--white local-button'
              {{on 'click' (fn this.toggleUpdateCollaborator)}}
            >
              {{t
                'components.project_settings.collaborators_item.cancel_save_role'
              }}
            </button>

            <button
              class='button button--filled local-button'
              {{on 'click' (fn this.updateCollaborator)}}
            >
              {{inlineSvg '/assets/check.svg' class='button-icon'}}
              {{t 'components.project_settings.collaborators_item.save_role'}}
            </button>
          {{/if}}
        {{else}}
          {{#if this.canUpdateCollaborator}}
            <button
              class='button button--filled button--white local-button'
              {{on 'click' (fn this.toggleUpdateCollaborator)}}
            >
              {{inlineSvg '/assets/pencil.svg' class='button-icon'}}
              {{t 'components.project_settings.collaborators_item.edit_role'}}
            </button>
          {{/if}}

          {{#if this.canDeleteCollaborator}}
            <button
              class='button button--filled button--red local-button'
              {{on 'click' (fn this.deleteCollaborator)}}
              data-test-collaborator-remove
            >
              {{inlineSvg '/assets/x.svg' class='button-icon'}}

              {{#if this.hasJoined}}
                {{t
                  'components.project_settings.collaborators_item.delete_button'
                }}
              {{else}}
                {{t
                  'components.project_settings.collaborators_item.uninvite_button'
                }}
              {{/if}}
            </button>
          {{/if}}
        {{/if}}
      </div>
    </li>
  </template>
  @service('session')
  declare session: Session;

  @service('intl')
  declare intl: IntlService;

  @service('global-state')
  declare globalState: GlobalState;

  @tracked
  isEditing = false;

  @tracked
  updatedRole = this.args.collaborator.role;

  @notEmpty('args.collaborator.user.id')
  hasJoined: boolean;

  get possibleRoles() {
    return this.globalState.roles.map(({slug}: {slug: string}) => slug);
  }

  get mappedPossibleRoles() {
    return this.possibleRoles.map((value) => ({
      label: this.intl.t(`general.roles.${value}`),
      value
    }));
  }

  get roleValue() {
    return this.mappedPossibleRoles.find(({value}) => {
      return value === this.updatedRole;
    });
  }

  get canDeleteCollaborator() {
    return (
      this.args.permissions &&
      this.args.permissions.createCollaborator &&
      (!this.args.collaborator.user ||
        (this.args.collaborator.user &&
          this.session.credentials.user?.id !== this.args.collaborator.user.id))
    );
  }

  get canUpdateCollaborator() {
    return (
      this.args.permissions &&
      this.args.permissions.updateCollaborator &&
      this.args.collaborator.user &&
      this.session.credentials.user?.id !== this.args.collaborator.user.id
    );
  }

  get role() {
    return this.intl.t(`general.roles.${this.args.collaborator.role}`);
  }

  @action
  setRole({value}: {value: string}) {
    this.updatedRole = value;
  }

  @action
  deleteCollaborator() {
    this.args.onDelete(this.args.collaborator);
  }

  @action
  async updateCollaborator() {
    await this.args.onUpdate(this.args.collaborator, {role: this.updatedRole});

    this.isEditing = false;
  }

  @action
  toggleUpdateCollaborator() {
    this.updatedRole = this.args.collaborator.role;
    this.isEditing = !this.isEditing;
  }
}
