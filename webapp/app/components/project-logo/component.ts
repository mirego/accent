import Component from '@glimmer/component';
import {htmlSafe} from '@ember/template';

const DEFAULT_PROJECT_LOGO = `
  <svg viewBox="0 0 480 480" xmlns="http://www.w3.org/2000/svg" fill-rule="evenodd" clip-rule="evenodd" stroke-linejoin="round" stroke-miterlimit="1.414">
    <circle cx="240" cy="240" r="239.334"></circle>
    <path d="M101.024 300.037l16.512 14.677s100.856-96.196 117.42-96.445c16.562-.25 126.59 92.77 126.59 92.77l17.43-15.6-116.5-142.19c-8.257-11.01-18.348-16.51-27.52-16.51-11.927 0-23.852 8.25-34.86 24.77l-99.072 138.52z" fill-rule="nonzero">
    </path>
  </svg>
`;

interface Args {
  logo: string;
}

export default class ProjectLogo extends Component<Args> {
  get safeLogo() {
    const logo = this.args.logo || DEFAULT_PROJECT_LOGO;

    return htmlSafe(logo);
  }
}
