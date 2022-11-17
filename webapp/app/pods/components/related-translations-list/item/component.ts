import {action} from '@ember/object';
import Component from '@glimmer/component';
import {tracked} from '@glimmer/tracking';

interface Args {
  onUpdateText: (translation: any, editText: string) => Promise<void>;
  isInEditMode: boolean;
  showEditButton: boolean;
  translation: any;
  project: any;
}

export default class RelatedTranslationsListItem extends Component<Args> {
  @tracked
  isSaving = false;

  @tracked
  editText = this.args.translation.correctedText;

  get showSaveButton() {
    if (this.args.translation.isRemoved) return false;

    return this.args.translation.correctedText !== this.editText;
  }

  get revisionName() {
    return (
      this.args.translation.revision.name ||
      this.args.translation.revision.language.name
    );
  }

  get revisionSlug() {
    return (
      this.args.translation.revision.slug ||
      this.args.translation.revision.language.slug
    );
  }

  get revisionTextDirRtl() {
    return this.args.translation.revision.rtl !== null
      ? this.args.translation.revision.rtl
      : this.args.translation.revision.language.rtl;
  }

  @action
  changeText(text: string) {
    this.editText = text;
  }

  @action
  async save() {
    this.isSaving = true;

    await this.args.onUpdateText(this.args.translation, this.editText);

    this.isSaving = false;
  }
}
