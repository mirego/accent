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
