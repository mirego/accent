import {action} from '@ember/object';
import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';

interface Args {
  project: any;
  revision: any;
  onUpdate: ({name, slug}: {name: string; slug: string}) => Promise<void>;
}

export default class RevisionUpdateForm extends Component<Args> {
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
