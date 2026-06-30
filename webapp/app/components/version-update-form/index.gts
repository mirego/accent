import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import {action} from '@ember/object';
import didInsert from '@ember/render-modifiers/modifiers/did-insert';
import t from 'ember-intl/helpers/t';
import {on} from '@ember/modifier';
import {fn} from '@ember/helper';
import {LinkTo} from '@ember/routing';
import AsyncButton from 'accent-webapp/components/async-button/index';

interface Args {
  version: any;
  error: boolean;
  project: any;
  onUpdate: (args: {
    tag: string;
    name: string;
    copyOnUpdateTranslation: boolean;
  }) => Promise<void>;
}

export default class VersionUpdateForm extends Component<Args> {
  <template>
    <div class='version-update-form' {{didInsert this.focusTextarea}}>
      <h1 class='title'>
        {{t 'components.version_update_form.title'}}
      </h1>

      {{#if @error}}
        <div class='errors'>
          <div class='error'>
            {{t 'components.version_update_form.error'}}
          </div>
        </div>
      {{/if}}

      <div class='formItem'>
        <label class='formItem-label'>
          {{t 'components.version_update_form.name_label'}}
        </label>

        <input
          value={{this.name}}
          class='textInput'
          {{on 'keyup' (fn this.setName)}}
        />
      </div>

      <div class='formItem'>
        <label class='formItem-label'>
          {{t 'components.version_update_form.tag_label'}}
        </label>

        <input
          value={{this.tag}}
          class='textInput'
          {{on 'keyup' (fn this.setTag)}}
        />
      </div>

      <div class='formItem'>
        <label class='formItem-label formItem-checkbox'>
          <input
            type='checkbox'
            checked={{this.copyOnUpdateTranslation}}
            {{on 'change' (fn this.setCopyOnUpdateTranslation)}}
          />
          {{t
            'components.version_update_form.copy_on_update_translation_label'
          }}
        </label>
        <p class='formItem-help'>
          {{t 'components.version_update_form.copy_on_update_translation_help'}}
        </p>
      </div>

      <div class='formActions'>
        <LinkTo
          @route='logged-in.project.versions'
          @model={{@project.id}}
          class='button button--filled button--white'
        >
          {{t 'components.version_update_form.cancel_button'}}
        </LinkTo>

        <AsyncButton
          class='button button--filled'
          @loading={{this.isCreating}}
          @onClick={{fn this.submit}}
        >
          {{t 'components.version_update_form.save_button'}}
        </AsyncButton>
      </div>
    </div>
  </template>
  @tracked
  name = this.args.version.name;

  @tracked
  tag = this.args.version.tag;

  @tracked
  copyOnUpdateTranslation = this.args.version.copyOnUpdateTranslation;

  @tracked
  isSubmitting = false;

  @action
  async submit() {
    this.isSubmitting = true;

    await this.args.onUpdate({
      tag: this.tag,
      name: this.name,
      copyOnUpdateTranslation: this.copyOnUpdateTranslation
    });

    if (!this.isDestroyed) this.isSubmitting = false;
  }

  @action
  setCopyOnUpdateTranslation(event: Event) {
    const target = event.target as HTMLInputElement;
    this.copyOnUpdateTranslation = target.checked;
  }

  @action
  setName(event: Event) {
    const target = event.target as HTMLInputElement;

    this.name = target.value;
  }

  @action
  setTag(event: Event) {
    const target = event.target as HTMLInputElement;

    this.tag = target.value;
  }

  @action
  focusTextarea(element: HTMLElement) {
    element.querySelector('input')?.focus();
  }
}
