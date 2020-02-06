import {action} from '@ember/object';
import {readOnly, not} from '@ember/object/computed';
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

  @not('args.translation.isRemoved')
  showSaveButton: boolean;

  @readOnly('args.translation.correctedText')
  editText: string;

  get revisionName() {
    return (
      this.args.translation.revision.name ||
      this.args.translation.revision.language.name
    );
  }

  @action
  async save() {
    this.isSaving = true;

    await this.args.onUpdateText(this.args.translation, this.editText);

    this.isSaving = false;
  }
}
