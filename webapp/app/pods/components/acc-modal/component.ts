import Component from '@glimmer/component';

interface Args {
  small: boolean;
  onClose: () => void;
}

export default class Modal extends Component<Args> {}
