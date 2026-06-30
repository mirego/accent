import Component from '@glimmer/component';
import t from 'ember-intl/helpers/t';
import {LinkTo} from '@ember/routing';
import inlineSvg from 'accent-webapp/helpers/inline-svg';
import {scopedClass} from 'ember-scoped-css';

interface Args {
  project: any;
}

export default class WelcomeProject extends Component<Args> {
  <template>
    <div class='welcome-project'>
      <h2 class='heroTitle'>
        <div class='heroTitle-title'>
          {{t 'components.welcome_project.welcome'}}
        </div>

        <div class='heroTitle-text'>
          {{t 'components.welcome_project.welcome_translations'}}
        </div>
      </h2>

      <h3 class='subtitle'>
        {{t 'components.welcome_project.first_step'}}:
      </h3>

      <div class='links'>
        <LinkTo
          @route='logged-in.project.files.new-sync'
          @model={{@project.id}}
          class='link'
        >
          {{inlineSvg 'assets/sync.svg' class=(scopedClass 'link-icon')}}

          <span class='link-title'>
            {{t 'components.welcome_project.sync_file'}}
            <span class='link-subtitle'>
              {{t 'components.welcome_project.sync_file_text'}}
            </span>
          </span>
        </LinkTo>

        <LinkTo
          @route='logged-in.project.manage-languages'
          @model={{@project.id}}
          class='link'
        >
          {{inlineSvg 'assets/language.svg' class=(scopedClass 'link-icon')}}
          <span class='link-title'>
            {{t 'components.welcome_project.manage_languages'}}
            <span class='link-subtitle'>
              {{t 'components.welcome_project.manage_languages_text'}}
            </span>
          </span>
        </LinkTo>

        <LinkTo
          @route='logged-in.project.collaborators'
          @model={{@project.id}}
          class='link'
        >
          {{inlineSvg 'assets/users.svg' class=(scopedClass 'link-icon')}}
          <span class='link-title'>
            {{t 'components.welcome_project.add_collaborator'}}
            <span class='link-subtitle'>
              {{t 'components.welcome_project.add_collaborator_text'}}
            </span>
          </span>
        </LinkTo>

        <LinkTo
          @route='logged-in.project.edit.api-token'
          @model={{@project.id}}
          class='link'
        >
          {{inlineSvg 'assets/code.svg' class=(scopedClass 'link-icon')}}
          <span class='link-title'>
            {{t 'components.welcome_project.api_token'}}
            <span class='link-subtitle'>
              {{t 'components.welcome_project.api_token_text'}}
            </span>
          </span>
        </LinkTo>
      </div>
    </div>
  </template>
}
