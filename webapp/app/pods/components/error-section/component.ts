import Component from '@glimmer/component';

interface Args {
  status: string;
  title: string;
  text: string;
  isAuthenticated: boolean;
  onLogout?: () => void;
}

export default class ErrorSection extends Component<Args> {}
