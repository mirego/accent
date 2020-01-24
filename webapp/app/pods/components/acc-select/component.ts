import Component from '@glimmer/component';

interface Args {
  searchEnabled: boolean;
  selected: any;
  options: any[];
  onchange: (value: any) => void;
  placeholder: string;
  search: (term: string) => Promise<any>;
  searchPlaceholder: string;
  matchTriggerWidth: boolean;
  renderInPlace: boolean;
}

export default class Select extends Component<Args> {}
