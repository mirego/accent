import Component from '@glimmer/component';
import config from 'accent-webapp/config/environment';

export default class ApplicationFooter extends Component {
  // The version is replaced at runtime when served by the API.
  // If the webapp is not served by the API (like in development),
  // the version tag will show up as empty.
  get version() {
    if (config.version === '__VERSION__') {
      return '';
    } else {
      return config.version;
    }
  }

  toggleDark() {
    document.documentElement.setAttribute('data-theme', 'dark');
    localStorage.setItem('theme', 'dark');
  }

  toggleLight() {
    document.documentElement.setAttribute('data-theme', 'light');
    localStorage.setItem('theme', 'light');
  }
}
