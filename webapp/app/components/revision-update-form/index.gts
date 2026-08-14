import {action} from '@ember/object';
import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';
import t from 'ember-intl/helpers/t';
import {on} from '@ember/modifier';
import {fn} from '@ember/helper';
import {LinkTo} from '@ember/routing';
import AsyncButton from 'accent-webapp/components/async-button/index';

interface Args {
  project: any;
  revision: any;
  onUpdate: ({name, slug}: {name: string; slug: string}) => Promise<void>;
}

export default class RevisionUpdateForm extends Component<Args> {
  <template>
    <div class='revision-update-form'>
      <h1 class='title'>
        {{t 'components.revision_update_form.title'}}
      </h1>

      <form {{on 'submit' (fn this.submit)}}>
        <div class='formItem'>
          <label class='formItem-label'>
            {{t 'components.revision_update_form.name_label'}}
          </label>

          <input
            placeholder={{this.namePlaceholder}}
            value={{this.name}}
            class='textInput'
            {{on 'keyup' (fn this.setName)}}
          />
        </div>

        <div class='formItem'>
          <label class='formItem-label'>
            {{t 'components.revision_update_form.slug_label'}}
          </label>
          <input
            placeholder={{this.slugPlaceholder}}
            value={{this.slug}}
            class='textInput'
            {{on 'keyup' (fn this.setSlug)}}
          />
        </div>

        <div class='formActions'>
          <LinkTo
            @route='logged-in.project.manage-languages'
            @model={{@project.id}}
            class='button button--filled button--white'
          >
            {{t 'components.revision_update_form.cancel_button'}}
          </LinkTo>

          <AsyncButton
            class='button button--filled'
            @loading={{this.isUpdating}}
            @onClick={{fn this.submit}}
          >
            {{t 'components.revision_update_form.save_button'}}
          </AsyncButton>
        </div>
      </form>
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
      .revision-update-form {
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

      .textInput {
        padding: 10px;
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

      .formActions {
        padding-top: 10px;
      }
    </style>
  </template>
  @tracked
  name = this.args.revision.name;

  @tracked
  slug = this.args.revision.slug;

  @tracked
  isUpdating = false;

  get namePlaceholder() {
    return this.args.revision.name || this.args.revision.language.name;
  }

  get slugPlaceholder() {
    return this.args.revision.slug || this.args.revision.language.slug;
  }

  @action
  async submit() {
    this.isUpdating = true;

    const name = this.name;
    const slug = this.slug;

    await this.args.onUpdate({name, slug});

    if (!this.isDestroyed) this.isUpdating = false;
  }

  @action
  setName(event: Event) {
    const target = event.target as HTMLInputElement;

    this.name = target.value;
  }

  @action
  setSlug(event: Event) {
    const target = event.target as HTMLInputElement;

    this.slug = target.value;
  }
}
