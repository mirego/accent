import {Config} from '../accent';
import State from '../state';
import randomClass from './random-class';
import styles from './styles';

const EXPAND_CLASS = randomClass();
const COLLAPSE_CLASS = randomClass();

interface Props {
  root: Element;
  config: Config;
  state: State;
}

/*
  The UI component is responsible of instanciating the Accent interface
  and the communication between the parent (the page that executes this script) and
  the embeded Accent client.

  All interactions from the parent window TO the Accent client go through here.
*/
export default class UI {
  private readonly overlay: HTMLElement;
  private readonly editor: HTMLElement;
  private readonly frame: HTMLIFrameElement;
  private readonly state: State;
  private readonly expandButton: Element;
  private readonly collapseButton: Element;

  constructor(props: Props) {
    this.state = props.state;

    this.overlay = this.buildOverlay();
    this.editor = this.buildContainer();
    this.frame = this.buildFrame(props.config);

    this.editor.append(this.frame);
    props.root.append(this.editor);
    props.root.append(this.overlay);

    this.expandButton = this.editor.getElementsByClassName(EXPAND_CLASS)[0];
    this.collapseButton = this.editor.getElementsByClassName(COLLAPSE_CLASS)[0];

    this.collapse();
  }

  bindEvents() {
    this.editor.addEventListener(
      'click',
      this.handleEditorToggle.bind(this),
      false
    );
  }

  hideOverlay() {
    this.overlay.remove();
  }

  showLogin() {
    styles.hide(this.expandButton);
    styles.set(this.editor, styles.frameCentered);
  }

  postMessage(message: object) {
    this.frame.contentWindow.postMessage({jipt: true, ...message}, '*');
  }

  collapse() {
    styles.set(this.editor, styles.frameCollapsed);
    styles.hide(this.collapseButton);
    styles.set(this.expandButton, styles.frameExpandButton);
  }

  expand() {
    styles.set(this.editor, styles.frameExpanded);
    styles.hide(this.expandButton);
    styles.set(this.collapseButton, styles.frameCollapseButton);
  }

  handleEditorToggle(event: MouseEvent) {
    const target = event.target as HTMLElement;

    if (target === this.collapseButton) {
      return this.collapse();
    }

    if (target === this.expandButton) {
      return this.expand();
    }
  }

  selectTranslation(id: string) {
    this.expand();
    this.postMessage({selectId: id});
  }

  selectTranslations(ids: string) {
    this.expand();
    this.postMessage({selectIds: ids});
  }

  private buildOverlay() {
    const element = document.createElement('div');
    styles.set(element, styles.overlay);

    return element;
  }

  private buildFrame(config) {
    const element = document.createElement('iframe');
    const query = this.state.getCurrentRevision()
      ? `?revisionId=${this.state.getCurrentRevision()}`
      : '';

    element.src = `${config.h}/app/projects/${config.i}/jipt${query}`;
    element.frameBorder = '0';
    styles.set(element, styles.frameWindow);

    return element;
  }

  private buildContainer() {
    const element = document.createElement('div');
    element.innerHTML = `
      <div class="${EXPAND_CLASS}" style="${styles.frameExpandButton}"></div>
      <div class="${COLLAPSE_CLASS}" style="${
      styles.frameCollapseButton
    }">×</div>
    `;

    return element;
  }
}
