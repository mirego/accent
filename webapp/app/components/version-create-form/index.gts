import Component from '@glimmer/component';
import {action} from '@ember/object';
import {tracked} from '@glimmer/tracking';
import didInsert from '@ember/render-modifiers/modifiers/did-insert';
import t from 'ember-intl/helpers/t';
import {on} from '@ember/modifier';
import {fn} from '@ember/helper';
import {LinkTo} from '@ember/routing';
import AsyncButton from 'accent-webapp/components/async-button/index';

interface Args {
  error: boolean;
  project: any;
  onCreate: (args: object) => Promise<void>;
}

export default class VersionCreateForm extends Component<Args> {
  <template>
    <div class='version-create-form' {{didInsert this.focusTextarea}}>
      <h1 class='title'>
        {{t 'components.version_create_form.title'}}
      </h1>

      <div class='text'>
        {{t 'components.version_create_form.text'}}
      </div>

      {{#if @error}}
        <div class='errors'>
          <div class='error'>
            {{t 'components.version_create_form.error'}}
          </div>
        </div>
      {{/if}}

      <div class='formItem'>
        <label class='formItem-label'>
          {{t 'components.version_create_form.name_label'}}
        </label>
        <input
          value={{this.name}}
          class='textInput'
          {{on 'keyup' (fn this.setName)}}
        />
      </div>

      <div class='formItem'>
        <label class='formItem-label'>
          {{t 'components.version_create_form.tag_label'}}
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
            'components.version_create_form.copy_on_update_translation_label'
          }}
        </label>
        <p class='formItem-help'>
          {{t 'components.version_create_form.copy_on_update_translation_help'}}
        </p>
      </div>

      <div class='formActions'>
        <LinkTo
          @route='logged-in.project.versions'
          @model={{@project.id}}
          class='button button--filled button--white'
        >
          {{t 'components.version_create_form.cancel_button'}}
        </LinkTo>
        <AsyncButton
          class='button button--filled'
          @loading={{this.isCreating}}
          @onClick={{fn this.submit}}
        >
          {{t 'components.version_create_form.save_button'}}
        </AsyncButton>
      </div>
    </div>

    <style scoped>
      .textInput {
        transition: 0.2s ease-in-out;
        transition-property: background, border, box-shadow;
        resize: vertical;
        outline: 0;
        border-radius: var(--border-radius);
        border: 2px solid var(--input-border-color);
        background: var(--input-background);
        color: var(--input-color);
        font-family: var(--font-monospace);
        line-height: 1.4;
        max-height: 200px;
      }
      .textInput::-moz-selection {
        background: color-mix(in srgb, var(--color-primary) 70%, transparent);
      }
      .textInput::selection {
        background: color-mix(in srgb, var(--color-primary) 70%, transparent);
      }
      .textInput:focus {
        border: 2px solid var(--color-primary);
      }
      .textInput:disabled {
        color: var(--color-grey);
        background: var(--background-light);
      }

      @media (hover: none) and (max-width: 640px) {
        .textInput {
          font-size: 16px !important;
        }
      }
      .version-create-form {
        padding: 20px;
        background: var(--content-background);
      }

      .title {
        margin-bottom: 20px;
        text-align: center;
        font-size: 27px;
        font-weight: 300;
        color: var(--color-primary);
      }

      .text {
        font-size: 13px;
        margin-bottom: 20px;
        color: #555;
      }

      .textInput {
        flex-grow: 1;
        flex-shrink: 0;
        padding: 10px;
        margin-right: 25px;
        min-width: 250px;
        width: 100%;
        font-size: 12px;
        font-family: var(--font-primary);
      }

      .errors {
        margin-bottom: 15px;
        padding-bottom: 5px;
      }

      .error {
        margin-bottom: 5px;
        color: var(--color-error);
        font-size: 13px;
        font-weight: bold;
      }

      .formItem {
        margin-bottom: 20px;
      }

      .formItem-label {
        display: block;
        margin-bottom: 8px;
        font-size: 13px;
      }

      .formItem-checkbox {
        margin-bottom: 4px;
        display: flex;
        align-items: center;
        gap: 6px;
      }

      .formItem-help {
        font-size: 11px;
        opacity: 0.6;
      }

      .formActions {
        padding-top: 10px;
      }
    </style>
  </template>
  @tracked
  name = '';

  @tracked
  tag = '';

  @tracked
  copyOnUpdateTranslation = true;

  @tracked
  isCreating = false;

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
  setCopyOnUpdateTranslation(event: Event) {
    const target = event.target as HTMLInputElement;
    this.copyOnUpdateTranslation = target.checked;
  }

  @action
  async submit() {
    this.isCreating = true;

    try {
      await this.args.onCreate({
        tag: this.tag,
        name: this.name,
        copyOnUpdateTranslation: this.copyOnUpdateTranslation
      });
    } finally {
      this.isCreating = false;
    }
  }

  @action
  focusTextarea(element: HTMLElement) {
    element.querySelector('input')?.focus();
  }
}
