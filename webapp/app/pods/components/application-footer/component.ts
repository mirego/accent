import Component from '@glimmer/component';

export default class ApplicationFooter extends Component {
  toggleDark() {
    document.documentElement.setAttribute('data-theme', 'dark');
    localStorage.setItem('theme', 'dark');
  }

  toggleLight() {
    document.documentElement.setAttribute('data-theme', 'light');
    localStorage.setItem('theme', 'light');
  }
}
