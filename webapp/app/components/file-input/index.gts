import {action} from '@ember/object';
import Component from '@glimmer/component';
import {on} from '@ember/modifier';
import {fn} from '@ember/helper';

interface Args {
  onChange: (files: FileList | null) => void;
}

export default class FileInput extends Component<Args> {
  <template>
    <input type='file' ...attributes {{on 'change' (fn this.onChange)}} />
  </template>
  @action
  onChange(event: Event) {
    const target = event.target as HTMLInputElement;

    this.args.onChange(target.files);
  }
}
