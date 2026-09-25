import type {Config} from './accent.ts';
import type LiveNode from './mutation/live-node.ts';
import Mutation from './mutation/mutation.ts';
import type State from './state.ts';
import type UI from './ui/ui.ts';


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

  private handleAccentMessage(event: MessageEvent) {
    if (!event.data?.jipt) return;

    switch (event.data.action) {
      case 'listTranslations':
        return this.handleListTranslations(event);
      case 'revisionNotFound':
        return this.handleRevisionNotFound();
      case 'redirectIfEmbedded':
        return this.ui.postMessage({projectId: this.projectId});
      case 'login':
        return this.ui.showLogin();
      case 'loggedIn':
        return this.ui.collapse();
      case 'changeText':
        return this.handleChangeText(event);
      case 'updateTranslation':
        return this.handleUpdateTranslation(event);
    }
  }

  private handleListTranslations(event: MessageEvent) {
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

  private handleRevisionNotFound() {
    if (!this.state.getCurrentRevision()) return;

    this.state.removeCurrentRevision();
    this.ui.reloadFrame();
  }

  private handleChangeText(event: MessageEvent) {
    const ref = this.state.refs.get(event.data.payload.translationId);
    if (!ref) return;

    ref.forEach((meta, node) => {
      if (!this.liveNode.isLive(node)) return;

      Mutation.nodeChange(node, meta, event.data.payload.text);
    });
  }

  private handleUpdateTranslation(event: MessageEvent) {
    const ref = this.state.refs.get(event.data.payload.translationId);
    if (!ref) return;

    ref.forEach((_meta, node) => {
      if (!this.liveNode.isLive(node)) return;

      Mutation.nodeStyleRefresh(node, event.data.payload);
    });
  }
}
