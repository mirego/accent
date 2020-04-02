import {Config} from './accent';
import LiveNode from './mutation/live-node';
import Mutation from './mutation/mutation';
import State from './state';
import UI from './ui/ui';

const enum ACTIONS {
  updateTranslation = 'updateTranslation',
  listTranslations = 'listTranslations',
  redirectIfEmbedded = 'redirectIfEmbedded',
  login = 'login',
  loggedIn = 'loggedIn',
  changeText = 'changeText',
}

interface Props {
  ui: UI;
  liveNode: LiveNode;
  config: Config;
  state: State;
}

/*
  The FrameListener component responds to the communication instantiated by the UI component.
  After receiving message from the Accent client, it can update the UI, refresh the page…

  It acts as the router of messages FROM the Accent client.
*/
export default class FrameListener {
  private readonly liveNode: LiveNode;
  private readonly state: State;
  private readonly ui: UI;
  private readonly projectId: string;

  constructor(props: Props) {
    this.ui = props.ui;
    this.state = props.state;
    this.liveNode = props.liveNode;
    this.projectId = props.config.i;
  }

  bindEvents() {
    window.addEventListener(
      'message',
      this.handleAccentMessage.bind(this),
      false
    );
  }

  private handleAccentMessage({data}) {
    if (!data.jipt) return;
    const action = data.action;

    if (action === ACTIONS.listTranslations) {
      return this.handleListTranslations(event);
    }

    if (action === ACTIONS.redirectIfEmbedded) {
      return this.handleRedirectIfEmbedded();
    }

    if (action === ACTIONS.login) {
      return this.handleLogin();
    }

    if (action === ACTIONS.loggedIn) {
      return this.handleLoggedIn();
    }

    if (action === ACTIONS.changeText) {
      return this.handleChangeText(event);
    }

    if (action === ACTIONS.updateTranslation) {
      return this.handleUpdateTranslation(event);
    }
  }

  private handleListTranslations(event) {
    const currentRevision = this.state.getCurrentRevision();
    const newRevision = event.data.payload.revisionId;
    this.state.projectTranslations = event.data.payload.translations;
    this.state.setCurrentRevision(newRevision);

    if (currentRevision && currentRevision !== newRevision) {
      window.location.reload();
    } else {
      this.ui.hideOverlay();
      this.liveNode.evaluate(document.body);
    }
  }

  private handleRedirectIfEmbedded() {
    this.ui.postMessage({projectId: this.projectId});
  }

  private handleLogin() {
    this.ui.showLogin();
  }

  private handleLoggedIn() {
    this.ui.collapse();
  }

  private handleChangeText(event) {
    const ref = this.state.refs.get(event.data.payload.translationId);
    if (!ref) return;

    ref.elements.forEach((meta, node: HTMLElement) => {
      if (!this.liveNode.isLive(node)) return;

      Mutation.nodeChange(node, meta, event.data.payload.text);
    });
  }

  private handleUpdateTranslation(event) {
    const ref = this.state.refs.get(event.data.payload.translationId);
    if (!ref) return;

    ref.elements.forEach((meta, node: HTMLElement) => {
      if (!this.liveNode.isLive(node)) return;

      Mutation.nodeStyleRefresh(node, event.data.payload);
    });
  }
}
