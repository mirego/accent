import {action} from '@ember/object';
import Component from '@glimmer/component';

interface Args {
  onChange: (files: FileList | null) => void;
}

export default class FileInput extends Component<Args> {
  @action
  onChange(event: Event) {
    const target = event.target as HTMLInputElement;

    this.args.onChange(target.files);
  }
}
